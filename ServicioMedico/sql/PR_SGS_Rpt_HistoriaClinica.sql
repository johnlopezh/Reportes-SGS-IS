USE [SGS]
GO
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_HistoriaClinica]    Script Date: 28/03/2017 8:39:15 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_HistoriaClinica.sql
DESCRIPCIÓN:			SP para la construcción del reporte de Historia Clínica 
						del modulo de Servicio Médico
PARAMETRO ENTRADA:		@idP_TipoDocumentoPersona = Tipo Documetno de Persona
						@ndP_NumeroDocumentoPersona = Número Documento de PersonaR
RESULTADO:				
CREACIÓN 
REQUERIMIENTO:			Reporte de Servicio Médico
AUTOR:					John Alberto López Hernández
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2017-03-13
----------------------------------------------------------------------------
MODIFICACIÓN:			Se incluyen los campos solicitados por el usuario
						dirección, ciudad, teléfono de la persona, 
						también se muestra los datos del Padre y Madre.
AUTOR:					John Alberto López Hernández	
****************************************************************************/
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_HistoriaClinica]

	 @idP_TipoDocumentoPersona varchar(30) 
	,@ndP_NumeroDocumentoPersona varchar(50)

AS BEGIN 

  SET NOCOUNT ON

  DECLARE @EsEstudiante AS bit;		
  DECLARE @AnioAcademicoActual AS int;
  DECLARE @Seccion AS int;
  DECLARE @TipoHorario AS int;
  DECLARE @Dia AS INT;

  SELECT
    @AnioAcademicoActual = Id
  FROM 
	PeriodoLectivo
  WHERE 
	AnioActivo = 1

/* Revisar que el numero de documento este en en la tabla estudiantes */ 

	SELECT
		@EsEstudiante = COUNT(NumeroIdentificacion)
	FROM 
		dbo.Estudiante
	WHERE 
		TipoIdentificacion = @idP_TipoDocumentoPersona
		AND NumeroIdentificacion = @ndP_NumeroDocumentoPersona

	IF @EsEstudiante = 1

 /*--------- CUANDO EL PACIENTEA ES ESTUDIANTE ---------------*/

	SELECT	

		DOC.Descripcion AS TipoIdentificacion
		,PR.NumeroIdentificacion AS NumeroIdentificacion
		,LEFT(CONVERT(varchar, PR.FechaNacimiento, 120), 10) AS FechaNac
		,dbo.F_SGS_CalcularEdadAniosMeses(PR.FechaNacimiento) AS Edad
		,ISNULL(PR.PrimerApellido, ' ') AS PrimerApellido
		,ISNULL(PR.SegundoApellido, ' ') AS SegundoApellido
		,ISNULL(PR.PrimerNombre, ' ') + ' ' + ISNULL(PR.SegundoNombre, ' ')  AS NombreCompleto
		,NAC.Descripcion AS LugarNacimiento
		,CUR.Nombre AS NombreCurso
		,PR.Celular AS Celular
		,GEN.Descripcion AS Genero
		,PR.UserName AS Email   
		,EST.CodigoEstudiante AS CodigoEstudiante
		,ESTC.Estado
		,IM.InstitucionCasoEmergencia
		,IM.MedicaTratante
		,IM.TelefonoMedicoTratante
		,DOM.Descripcion AS EPS
		,DOMP.Descripcion AS MedicinaPrepagada
		,PR.UrlFoto
		,'Estudiante' AS TipoPaciente 
		,DC.TelefonoDireccion AS TeléfonoCasa
		,DC.Barrio AS Barrio
		,DC.Direccion AS Direccion
		,CIUD.Nombre AS CiudadDireccion
		/** Información Padre de Familia */
		,PSP.PrimerApellido +' '+ isNull(PSP.SegundoApellido,'') + ' ' + PSP.PrimerNombre + ' '+ isNull(PSP.SegundoNombre,'') AS NombrePadre
		,PDP.TelefonoOficina AS TelefonoOficinaPadre
		,PSP.Celular AS CelularPadre
		/** Información Madre de Familia */
		,PSM.PrimerApellido +' '+ isNull(PSM.SegundoApellido,'') + ' ' + PSM.PrimerNombre + ' '+ isNull(PSM.SegundoNombre,'') AS NombreMadre
		,PDM.TelefonoOficina AS TelefonoOficinaMadre
		,PSM.Celular AS CelularMadre
		,TPP.Descripcion AS Padre
		,TPM.Descripcion as Madre

    FROM Persona AS PR

		INNER JOIN Estudiante AS EST WITH (NOLOCK)
		ON 	EST.TipoIdentificacion = PR.TipoIdentificacion
		AND EST.NumeroIdentificacion = PR.NumeroIdentificacion

		INNER JOIN EstudianteCurso AS ESTC WITH (NOLOCK)
		ON 	EST.TipoIdentificacion = ESTC.TipoIdentificacionEstudiante
		AND EST.NumeroIdentificacion = ESTC.NumeroIdentificacionEstudiante
	
		INNER JOIN Curso AS CUR WITH (NOLOCK)
		ON CUR.IdCurso = ESTC.IdCurso
	
		INNER JOIN Ciudad AS CIU WITH (NOLOCK)
		ON PR.LugarExpedicion = CIU.Id
	
		INNER JOIN Nacionalidad AS NAC WITH (NOLOCK)
		ON PR.PaisNacimiento = NAC.Codigo
	
		INNER JOIN GrupoFamiliar AS GF WITH (NOLOCK)
		ON 	GF.TipoIdentificacionMiembro = PR.TipoIdentificacion
		AND GF.NumeroIdentificacionMiembro = PR.NumeroIdentificacion
	
		INNER JOIN Direccion AS DC WITH (NOLOCK) 
		ON  DC.IdGrupoFamiliar = GF.IdFamilia
		AND DC.DireccionPrincipal = 1

		INNER JOIN Ciudad AS CIUD WITH (NOLOCK)
		ON DC.IdCiudad = CIUD.Id

		INNER JOIN Familia AS FM WITH (NOLOCK) 
		ON FM.IdFamilia= GF.IDFAMILIA 

		INNER JOIN Persona AS PSP WITH (NOLOCK) 
		ON PSP.TipoIdentificacion = FM.TipoDocumentoPadre
		AND PSP.NumeroIdentificacion = FM.NumeroDocumentoPadre
	
		INNER JOIN Padre AS PDP WITH (NOLOCK) 
		ON 	PDP.TipoIdentificacion = PSP.TipoIdentificacion
		AND PDP.NumeroIdentificacion = PSP.NumeroIdentificacion

		INNER JOIN Persona AS PSM WITH (NOLOCK) 
		ON 	PSM.TipoIdentificacion = FM.TipoDocumentoMadre
		AND PSM.NumeroIdentificacion = FM.NumeroDocumentoMadre

		INNER JOIN Padre AS PDM WITH (NOLOCK) 
		ON 	PDM.TipoIdentificacion = PSP.TipoIdentificacion
		AND PDM.NumeroIdentificacion = PSP.NumeroIdentificacion

		INNER JOIN InformacionMedica AS IM WITH (NOLOCK)
		ON 	PR.TipoIdentificacion = IM.TipoIdentificacion
		AND PR.NumeroIdentificacion = IM.NumeroIdentificacion

		INNER JOIN Dominio AS DOC WITH (NOLOCK)
		ON	DOC.Dominio = 'TipoDocumento'
		AND DOC.Valor = PR.TipoIdentificacion

		INNER JOIN Dominio AS GEN  WITH (NOLOCK)
		ON	GEN.Dominio = 'Genero'
		AND GEN.Valor = PR.Genero

		INNER JOIN Dominio AS DOM WITH (NOLOCK)
		ON	DOM.Dominio = 'EPS'
		AND DOM.Valor = IM.IdEPS

		INNER JOIN Dominio AS TPP WITH (NOLOCK)
		ON TPP.Dominio = 'TipoPadre'
		AND TPP.Valor = PDP.TipoPadre

		INNER JOIN Dominio AS TPM WITH (NOLOCK)
		ON TPM.Dominio = 'TipoPadre'
		AND TPM.Valor = PDM.TipoPadre

		LEFT JOIN Dominio AS DOMP WITH (NOLOCK)
		ON  DOMP.Dominio = 'MedicinaPrepagada' 		
		AND DOMP.Valor = IM.IdMedicinaPrepagada

    WHERE 
		EST.TipoIdentificacion = @idP_TipoDocumentoPersona
		AND EST.NumeroIdentificacion = @ndP_NumeroDocumentoPersona
		AND CUR.AnioAcademico = @AnioAcademicoActual

  ELSE
  
  /*--------- CUANDO EL PACIENTEA ES EMPLEADO ---------------*/

    SELECT

		 DOC.Descripcion AS TipoIdentificacion
		,PR.NumeroIdentificacion
		,LEFT(CONVERT(varchar, PR.FechaNacimiento, 120), 10) AS FechaNac
		,dbo.F_SGS_CalcularEdadAniosMeses(PR.FechaNacimiento) AS Edad
		,ISNULL(PR.PrimerApellido, ' ') AS PrimerApellido
		,ISNULL(PR.SegundoApellido, ' ') AS SegundoApellido
		,ISNULL(PR.PrimerNombre, ' ') + ' ' + ISNULL(PR.SegundoNombre, ' ')  AS NombreCompleto
		,NAC.Descripcion AS LugarNacimiento
		,PR.Celular
		,GEN.Descripcion AS Genero
		,PR.UserName AS Email
		,IM.InstitucionCasoEmergencia
		,IM.MedicaTratante
		,IM.TelefonoMedicoTratante
		,DOM.Descripcion AS EPS
		,DOMP.Descripcion AS MedicinaPrepagada
		,PR.UrlFoto
		,'Empleado' AS TipoPaciente	
		,DC.TelefonoDireccion AS TeléfonoCasa
		,DC.Barrio AS Barrio
		,DC.Direccion AS Direccion
		,CIUD.Nombre AS CiudadDireccion

    FROM Persona AS PR

		INNER JOIN Ciudad AS CIU WITH (NOLOCK)
		ON PR.LugarExpedicion = CIU.Id

		INNER JOIN Nacionalidad AS NAC WITH (NOLOCK)
		ON PR.PaisNacimiento = NAC.Codigo

		INNER JOIN Dominio AS DOC WITH (NOLOCK)
		ON DOC.Dominio = 'TipoDocumento'
		AND DOC.Valor = PR.TipoIdentificacion

		INNER JOIN Dominio AS GEN WITH (NOLOCK)
		ON GEN.Dominio = 'Genero'
		AND GEN.Valor = PR.Genero

		INNER JOIN GrupoFamiliar AS GF WITH (NOLOCK)
		ON GF.TipoIdentificacionMiembro = PR.TipoIdentificacion
		AND GF.NumeroIdentificacionMiembro = PR.NumeroIdentificacion
	
		INNER JOIN Direccion AS DC WITH (NOLOCK) 
		ON  DC.IdGrupoFamiliar = GF.IdFamilia
		AND DC.DireccionPrincipal = 1

		INNER JOIN Ciudad AS CIUD WITH (NOLOCK)
		ON DC.IdCiudad = CIUD.Id

		LEFT JOIN InformacionMedica AS IM WITH (NOLOCK)
		ON	PR.TipoIdentificacion = IM.TipoIdentificacion
		AND PR.NumeroIdentificacion = IM.NumeroIdentificacion

		LEFT JOIN Dominio AS DOM WITH (NOLOCK)
		ON 	DOM.Dominio = 'EPS'
		AND DOM.Valor = IM.IdEPS

		LEFT JOIN Dominio AS DOMP WITH (NOLOCK)
		ON 	DOM.Dominio = 'MedicinaPrepagada' 		
		AND DOM.Valor = IM.IdMedicinaPrepagada

    WHERE 
		PR.TipoIdentificacion = @idP_TipoDocumentoPersona
		AND PR.NumeroIdentificacion = @ndP_NumeroDocumentoPersona
END 