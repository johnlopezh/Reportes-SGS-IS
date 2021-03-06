USE [SGS]
GO
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_InformeAtencionCADI]    Script Date: 10/02/2017 10:01:21 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:				dbo.PR_SGS_Rpt_InformeAtencionEspecialistaCADI.sql
DESCRPCIÓN:			Creación Strored Procedures "Informe Atención por 
					rango de fechas atención CADI"
AUTOR:				John Alberto López Hernández
REQUERIMIENTO:		SP40 - Transporte
EMPRESA:			Colegio San Jorge de Inglaterra
FECHA CREACIÓN:		11/11/2016
PARÁMETROS ENTRADA: 	 
					 @PEstudiante
					,@idP_FechaInicio 
					,@idP_FechaFin 
					,@idP_Especialidad 
EXCEPCIONES:		No Aplica
---------------------------------------------------------------------
MODIFICACIÓN:       Se modifican los parametros por tipo y numero de 
					identificación, se implementa la busqueda por 
					nombres.
AUTOR:				John Alberto López Hernández
REQUERIMIENTO:		
Oficina:			CADI
FECHA MODIFICACIÓN:	14 de Mayo de 2017
*****************************+***************************************/
ALTER PROCEDURE 
	 [dbo].[PR_SGS_Rpt_InformeAtencionEspecialistaCADI]  
		 @PEstudiante VARCHAR (100)
		,@idP_FechaInicio DATETIME
		,@idP_FechaFin DATETIME
		,@idP_Especialidad VARCHAR (30)
AS
BEGIN
DECLARE @Especialidades TABLE 
	(
		IdEspecialidad VARCHAR(60)
	)
INSERT INTO @Especialidades
SELECT ESPE.Valor AS Especialidad
FROM F_SGS_Split(@idP_Especialidad, ',') AS ESPE
SELECT 
	CONVERT (VARCHAR(10),NVM.Fecha1,103) AS FechaSesion
	,PR.PrimerApellido + ' ' + isNull(PR.SegundoApellido,'') + ' ' + PR.PrimerNombre + ' ' + isNull(PR.SegundoNombre,'')  AS NombrePaciente
	,[dbo].[F_SGS_CalcularEdadAniosMeses] (PR.FechaNacimiento) AS Edad
	,NVM.NombreNovedad AS NombreNovedad
	,TNM.Nombre	AS NombreTipoNovedad
	,DOM.Descripcion AS Especialidad
	,NVM.Descripcion AS Descripcion
	,CR.Nombre AS Curso
	,MAT.Nombre AS Materia 
	,HO.Dia AS DiaAcademico
	,CAL.NumeroCiclo AS NumeroCiclo
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
INNER JOIN Curso as CR
	ON ES.IdCurso = CR.IdCurso 
INNER JOIN Nivel as NV
	ON CR.IdNivel = NV.IdNivel
INNER JOIN Seccion AS SE
	ON NV.IdSeccion = SE.IdSeccion
INNER JOIN PeriodoLectivo AS PL
	ON CR.AnioAcademico = PL.ID
	AND PL.AnioActivo = '1'
INNER JOIN TipoNovedadMedica AS TNM 
	ON NVM.IdTipoNovedad = TNM.IdTipoNovedadMedica
INNER JOIN TipoNovedadMedicaPestania AS TNMP
	ON TNM.IdTipoNovedadMedica = TNMP.IdTipoNovedadMedica
INNER JOIN Usuario AS USR
	ON NvM.UsuarioLog = USR.mail
LEFT JOIN CALENDARIO AS CAL 
	ON NVM.FECHA1=CAL.FECHA
LEFT JOIN TipoHorario AS TH
	ON TH.IdTipoHorario = CASE 
					WHEN SE.IdSeccion = 1 THEN CAL.TipoHorarioPreescolar 
					WHEN SE.IdSeccion = 2 THEN CAL.TipoHorarioPrimaria
					WHEN SE.IdSeccion = 3 THEN CAL.TipoHorarioBachillerato
				END 
	AND  CONVERT(VARCHAR(50),TH.NumeroHora)= NVM.CampoTexto4
LEFT JOIN Horario AS HO
	ON TH.NumeroHora = HO.Hora 
	AND HO.IdCurso = CR.IdCurso 
	AND HO.Dia = cal.NumeroDia
LEFT JOIN Materia AS MAT
	ON HO.IdMateria = MAT.Id
INNER JOIN DOMINIO DOM 
	ON NVM.ValorDominio = DOM.Valor
	AND DOM.Dominio = 'EspecialidadCADI'
INNER JOIN @Especialidades AS ESPEC
	ON NVM.ValorDominio = ESPEC.IdEspecialidad
WHERE 
	TNMP.IdPestaniaDashboard IN (9,4)
	AND PNM.NumeroIdentificacionPersona = @PEstudiante
	AND NVM.Fecha1 BETWEEN @idP_FechaInicio AND @idP_FechaFin
ORDER BY
	NVM.Fecha1 DESC
END