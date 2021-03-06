SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:				dbo.PR_SGS_DatosPersonalesEstudiante.sql
DESCRPCI�N:			Creaci�n Strored Procedures "Consulta Asistencia Refuerzos
AUTOR:				John Alberto L�pez Hern�ndez
REQUERIMIENTO:		Matr�culas
EMPRESA:			Colegio San Jorge de Inglaterra
FECHA CREACI�N:		23/03/2017
PAR�METROS ENTRADA:	No Aplica
EXCEPCIONES:		No Aplica
------------------------------------------------------------------------------------------   
*******************************************************************************************/
CREATE PROCEDURE 
	 [dbo].[PR_SGS_DatosPersonalesEstudiante] 
	 /* Espacio parametros */


AS
BEGIN

SELECT 
	 PR.PrimerApellido +' '+ isNull(PR.SegundoApellido,'') + ' ' + PR.PrimerNombre + ' '+ isNull(PR.SegundoNombre,'') AS NombreEstudiante
	,PR.TipoIdentificacion +' '+ PR.NumeroIdentificacion AS IdentificacionEstudiante
	,DC.TelefonoDireccion AS Tel�fonoCasa
	,DC.Barrio AS Barrio
	,DC.Direccion AS Direccion
	,ED.CodigoEstudiante AS CodigoEstudiante
	,EC.Estado AS EstadoEstudiante
	,CR.Nombre AS Curso
	,NV.Nombre AS Nivel
	,SE.Nombre AS Seccion
	/** Informaci�n Padre de Familia */
	,PSP.PrimerApellido +' '+ isNull(PSP.SegundoApellido,'') + ' ' + PSP.PrimerNombre + ' '+ isNull(PSP.SegundoNombre,'') AS NombrePadre
	,PSP.TipoIdentificacion +' '+ PSP.NumeroIdentificacion AS IdentificacionPadre
	,PDP.Titulo AS ProfesionPadre
	,PDP.Empresa AS EmpresaPadre
	,PDP.TelefonoOficina AS TelefonoOficinaPadre
	,PSP.Celular AS CelularPadre
	,PSP.USERNAME AS CorreoPadre
	/** Informaci�n Madre de Familia */
	,PSM.PrimerApellido +' '+ isNull(PSM.SegundoApellido,'') + ' ' + PSM.PrimerNombre + ' '+ isNull(PSM.SegundoNombre,'') AS NombreMadre
	,PSM.TipoIdentificacion +' '+ PSM.NumeroIdentificacion AS IdentificacionMadre
	,PDM.Titulo AS ProfesionMadre
	,PDM.Empresa AS EmpresaMadre
	,PDM.TelefonoOficina AS TelefonoOficinaMadre
	,PSM.Celular AS CelularMadre
	,PSM.USERNAME AS CorreoMadre
	/** Informaci�n Acudiente */
	,PSA.PrimerApellido +' '+ isNull(PSA.SegundoApellido,'') + ' ' + PSA.PrimerNombre + ' '+ isNull(PSA.SegundoNombre,'') AS NombreAcudiente
	,PSA.TipoIdentificacion +' '+ PSA.NumeroIdentificacion AS IdentificacionAcudiente
	,PSA.Celular AS CelularAcudiente
	/** Informaci�n Transporte */
	,BRTA.DominioNombreRuta AS Ruta
FROM PERSONA AS PR WITH (NOLOCK) 
	/* Informaci�n Academica */
	JOIN ESTUDIANTE AS ED WITH (NOLOCK) ON
	ED.TIPOIDENTIFICACION =  PR.TIPOIDENTIFICACION 
	AND ED.NUMEROIDENTIFICACION = PR.NUMEROIDENTIFICACION

	JOIN ESTUDIANTECURSO AS EC WITH (NOLOCK) ON
	ED.TIPOIDENTIFICACION = EC.TIPOIDENTIFICACIONESTUDIANTE 
	AND ED.NUMEROIDENTIFICACION = EC.NUMEROIDENTIFICACIONESTUDIANTE

	JOIN CURSO AS CR WITH (NOLOCK) 
	ON EC.IdCURSO = CR.IdCurso

	JOIN NIVEL AS NV WITH (NOLOCK) 
	ON CR.IdNivel = NV.IdNivel

	JOIN SECCION AS SE WITH (NOLOCK) 
	ON NV.IdSeccion = SE.IdSeccion
	/* Datos Personal e Informaci�n Familiar */
	JOIN GRUPOFAMILIAR AS GF WITH (NOLOCK)
	ON 	GF.TIPOIDENTIFICACIONMIEMBRO = PR.TIPOIDENTIFICACION 
	AND GF.NUMEROIDENTIFICACIONMIEMBRO = PR.NUMEROIDENTIFICACION
	
	JOIN DIRECCION AS DC WITH (NOLOCK) 
	ON  DC.IDGRUPOFAMILIAR = GF.IDFAMILIA 
	AND DIRECCIONPRINCIPAL = 1
	
	JOIN FAMILIA AS FM WITH (NOLOCK) ON
	FM.IDFAMILIA = GF.IDFAMILIA 

	JOIN PERSONA AS PSA WITH (NOLOCK) ON
	PSA.TIPOIDENTIFICACION = ED.TIPOIDENTIFICACIONACUDIENTE 
	AND PSA.NUMEROIDENTIFICACION = ED.NUMEROIDENTIFICACIONACUDIENTE

	JOIN PERSONA AS PSP WITH (NOLOCK) ON
	PSP.TIPOIDENTIFICACION = FM.TIPODOCUMENTOPADRE 
	AND PSP.NUMEROIDENTIFICACION = FM.NUMERODOCUMENTOPADRE
	
	JOIN PADRE AS PDP WITH (NOLOCK) ON
	PDP.TIPOIDENTIFICACION = PSP.TIPOIDENTIFICACION 
	AND PDP.NUMEROIDENTIFICACION = PSP.NUMEROIDENTIFICACION 

	JOIN PERSONA AS PSM WITH (NOLOCK) ON
	PSM.TIPOIDENTIFICACION = FM.TIPODOCUMENTOMADRE 
	AND PSM.NUMEROIDENTIFICACION = FM.NUMERODOCUMENTOMADRE

	JOIN PADRE AS PDM WITH (NOLOCK) ON
	PDM.TIPOIDENTIFICACION = PSP.TIPOIDENTIFICACION 
	AND PDM.NUMEROIDENTIFICACION = PSP.NUMEROIDENTIFICACION 

	/* Informaci�n Transporte */

	JOIN PersonaRuta AS PRT WITH (NOLOCK)
	ON PR.TipoIdentificacion = PRT.TipoIdentificacionPasajero
	AND PR.NumeroIdentificacion = PRT.NumeroIdentificacionPasajero

	JOIN BusRuta AS BRTA WITH (NOLOCK)
	ON PRT.IdBusRuta = BRTA.IdBusRuta

	LEFT JOIN PreRuta AS PRE WITH (NOLOCK)
	ON PRE.IdPersonaRuta = PRT.IdPersonaRuta

    LEFT JOIN vw_ServiciosTransporte  AS ST on 
	st.CodigoServicio = BRTA.DominioJornada

WHERE 
	EC.Estado <> 'Retirado'
	AND PR.TipoIdentificacion = 'TI'
	AND PR.NumeroIdentificacion = '1188213685'
	AND CR.AnioAcademico = 2
	AND FechaCalendario = '19000101' 
	AND PRT.Estado = 'Activo'
END 