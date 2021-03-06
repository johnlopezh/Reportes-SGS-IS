USE [SGS]
GO
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_AntecedentesCADI]    Script Date: 27/03/2017 7:52:09 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:				dbo.PR_SGS_Rpt_AntecedentesCADI.sql
DESCRPCIÓN:			Creación Strored Procedures "Informe Antecedentes CADI"
AUTOR:				John Alberto López Hernández
REQUERIMIENTO:		SP40 - Transporte
EMPRESA:			Colegio San Jorge de Inglaterra
FECHA CREACIÓN:		11/11/2016
PARÁMETROS ENTRADA:	No Aplica
EXCEPCIONES:		No Aplica
----------------------------------------------------------------------
MODIFICACIÓN:       Se modifican los parametros de consulta de estudiantes 
					se implementa la busqueda por nombre, ingresando caracteres
					del nombre usando del 
					SP PR_SGS_Rpt_ConsultaEstudiantesPorNombre.sql
					se agrega el parametro @PEstudiante para mostrar los resultados
					de los posibles nombres, también de modifica el WHERE
AUTOR:				John Alberto López		
REQUERIMIENTO:		
Oficina:			CADI
FECHA MODIFICACIÓN:	14 de Mayo de 2017
********************************************************************/
ALTER PROCEDURE 
	 [dbo].[PR_SGS_Rpt_AntecedentesCADI] 
		@PEstudiante VARCHAR (100)
AS
BEGIN
SELECT 
	CONVERT (VARCHAR(10),NVM.Fecha1,110) AS FechaSesion
	,PR.PrimerApellido + ' ' + isNull(PR.SegundoApellido,'') + ' ' + PR.PrimerNombre + ' ' + isNull(PR.SegundoNombre,'')  AS NombrePaciente
	,PR.FechaNacimiento AS FechaNacimiento
	,[dbo].[F_SGS_CalcularEdadAniosMeses] (PR.FechaNacimiento) AS Edad
	,DIR.Direccion AS Direccion
	,DIR.TelefonoDireccion AS Telefono
	,NVM.NombreNovedad AS NumeroSesion
	,CR.Nombre AS Curso
	,MADRE .PrimerApellido + ' ' + isNull(MADRE .SegundoApellido,'') + ' ' + MADRE .PrimerNombre + ' ' + isNull(MADRE.SegundoNombre,'')  AS NombreMadre
	,MADRE.Celular AS TelefonoMadre
	,OFM.Ocupacion AS OcupacionMadre
	,PADRE .PrimerApellido + ' ' + isNull(PADRE .SegundoApellido,'') + ' ' + PADRE .PrimerNombre + ' ' + isNull(PADRE.SegundoNombre,'')  AS NombrePadre
	,PADRE.Celular AS TelefonoPadre
	,OFP.Ocupacion AS OcupacionPadre
FROM NovedadMedica  AS NVM
	INNER JOIN PersonaNovedadMedica AS PNM 
	ON NVM.IdNovedadMedica = PNM.IdNovedadMedica
	INNER JOIN Persona AS PR
	ON PNM.TipoIdentificacionPersona = PR.TipoIdentificacion 
	AND PNM.NumeroIdentificacionPersona = PR.NumeroIdentificacion
	INNER JOIN EstudianteCurso AS ES 
	ON PNM.TipoIdentificacionPersona = ES.TipoIdentificacionEstudiante
	AND PNM.NumeroIdentificacionPersona = ES.NumeroIdentificacionEstudiante
	AND ES.Estado <> 'Retirado'
	INNER JOIN GrupoFamiliar AS GF 
	ON  GF.TipoIdentificacionMiembro = PR.TipoIdentificacion 
	AND GF.NumeroIdentificacionMiembro = PR.NumeroIdentificacion 
	INNER JOIN Familia AS F 
	ON F.IdFamilia = GF.IdFamilia 
	INNER JOIN Direccion AS DIR 
	ON F.IdFamilia = DIR.IdGrupoFamiliar 
	AND DIR .DireccionPrincipal = 1 
	INNER JOIN Persona AS MADRE 
	ON F.TipoDocumentoMadre = MADRE.TipoIdentificacion 
	AND F.NumeroDocumentoMadre = MADRE.NumeroIdentificacion 
	INNER JOIN Persona AS PADRE 
	ON  F.TipoDocumentoPadre = PADRE.TipoIdentificacion 
	AND F.NumeroDocumentoPadre = PADRE.NumeroIdentificacion 
	INNER JOIN PADRE AS OFM
	ON MADRE.TipoIdentificacion  = OFM.TipoIdentificacion 
	AND MADRE.NumeroIdentificacion = OFM.NumeroIdentificacion
	INNER JOIN PADRE AS OFP
	ON PADRE.TipoIdentificacion  = OFP.TipoIdentificacion 
	AND PADRE.NumeroIdentificacion = OFP.NumeroIdentificacion
	INNER JOIN Curso as CR
	ON ES.IdCurso = CR.IdCurso 
	INNER JOIN PeriodoLectivo AS PL
	ON CR.AnioAcademico = PL.ID
	AND PL.AnioActivo = '1'
WHERE 
	PNM.NumeroIdentificacionPersona = @PEstudiante 
END