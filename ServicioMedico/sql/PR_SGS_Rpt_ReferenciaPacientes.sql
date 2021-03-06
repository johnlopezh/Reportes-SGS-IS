USE [SGS]
GO
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_ReferenciaPacientes]    Script Date: 16/03/2017 7:37:34 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*MODIFICACIONES
-------------------------------------------------------------------------------------------------------------------
VERSIÓN		USUARIO			FECHA MODIFICACIÓN		DESCRIPCIÓN
-------------------------------------------------------------------------------------------------------------------
1.1			RLEGUIZAMO		30/07/2015				Se adicionan campos en el select para mostrar la referencia de
													pacientes en el reporte. Adicionalmente, se adiciona LEFT JOIN.
													Se adicionan valores parametrizados.
----------------------------------------------------------------------------------------------------
MODIFICACION:		Se agrego el campo examen de referencia de la tabla Evolucion. Cambio 3589.
AUTOR:				Diana Hernandez
EMPRESA:			Asesoftware S.A.S
FECHA CREACIÓN:		11-04-2016
----------------------------------------------------------------------------------------------------
MODIFICACION:		Se inlcuye el parametro @NombreRolProfesional, que es el nombre de la medica o enferemera que ingrese al sistema. Cambio 3589.
AUTOR:				Diana Hernandez
EMPRESA:			Asesoftware S.A.S
FECHA CREACIÓN:		14-04-2016
----------------------------------------------------------------------------------------------------
MODIFICACION:		Se agrega el campo MotivoConsulta para que se visualice en el reporte.
AUTOR:				Diana Hernandez
EMPRESA:			Asesoftware S.A.S
FECHA CREACIÓN:		14-04-2016
----------------------------------------------------------------------------------------------------
MODIFICACION:		Se Corrige el campo fecha para que cuando sea null se muestre la fecha actual.
AUTOR:				Diana Hernandez
EMPRESA:			Asesoftware S.A.S
FECHA CREACIÓN:		04-05-2016
----------------------------------------------------------------------------------------------------
MODIFICACIÓN:	Se agrega como variable @FamiliaPrincipal para poner como condición
				que la persona se encuentre en una familia principal
REQUERIMIENTO:	SP38 - Bug# 4185	
AUTOR:			Héctor Arias	
EMPRESA:		Asesoftware S.A.S.
FECHA DE MODIFICACIÓN: 2016-10-06
****************************************************************************************************/
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_ReferenciaPacientes] 
	@IdEvolucion INT,
	@sP_usuarioAutenticado VARCHAR(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARACIÓN DE VARIABLES DE ENTRADA
    DECLARE @DominioEPS VARCHAR(30) = 'EPS',
			@NombrePrestador VARCHAR(50),
			@NITPrestador VARCHAR(50),
			@CodigoPrestador VARCHAR(50),
			@DireccionPrestador VARCHAR(50),
			@CiudadPrestador VARCHAR(50),
			@TelefonoPrestador VARCHAR(50),
			@TelefonoProfesional VARCHAR(50),
			@NombreUsuarioAutenticado VARCHAR(100),
			@RegistroMedico VARCHAR(100),
			@NombreRolProfesional VARCHAR(100)

	/*****************************************************************************
	--SE DECLARA LA CONSULTA PARA LA FAMILIA PRINCIPAL
	*****************************************************************************/
	DECLARE @FamiliaPrincipal BIT
	SET @FamiliaPrincipal = 1;
		 
	
	--ASIGNAR LOS VALORES A CADA VARIABLE OBTENIDOS DE PARÁMETROS
	SET @NombrePrestador = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'NombrePrestador')
	SET @NITPrestador = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'NITPrestador')
	SET @CodigoPrestador = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'CodigoPrestador')
	SET @DireccionPrestador = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'DireccionPrestador')
	SET @CiudadPrestador = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'CiudadPrestador')
	SET @TelefonoPrestador = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'TelefonoPrestador')
	SET @TelefonoProfesional = (SELECT P.Valor FROM dbo.Parametro AS P WITH(NOLOCK) WHERE P.Descripcion = 'TelefonoProfesional')

	--CONSULTA USUARIO AUTENTICADO
	SELECT @NombreUsuarioAutenticado = UPPER(per.PrimerNombre + ' ' + per.SegundoNombre + ' ' +per.PrimerApellido),---, per.Username
		   @NombreRolProfesional = (per.PrimerNombre + ' ' + per.SegundoNombre + ' ' +per.PrimerApellido + ' ' + per.SegundoApellido )
    FROM persona per
    WHERE per.Username= @sP_usuarioAutenticado;

		--CONSULTA DOMINIOS
	SELECT @RegistroMedico = Descripcion 
	FROM Dominio
	WHERE dominio='RegistroMedico' and Valor= @sP_usuarioAutenticado 

	--CONSULTAR LA EVOLUCIÓN PARA VISUALIZAR CAMPOS EN REPORTE
	SELECT	  
		  E.Id AS IdEvolucion
		, E.FechaIngreso AS FechaRemision
		, CASE 
		    WHEN E.HoraFin IS null THEN CONVERT(VARCHAR(8),DATEADD(HOUR,-5,GETDATE()),108)
			ELSE CONVERT(VARCHAR(8),E.HoraFin,108)  END AS HoraCierre
		, @NombrePrestador AS NombrePrestador
		, @NITPrestador AS NITPrestador
		, @CodigoPrestador AS CodigoPrestador
		, @DireccionPrestador AS DireccionPrestador
		, @CiudadPrestador AS CiudadPrestador
		, @TelefonoPrestador AS TelefonoPrestador
		, @TelefonoProfesional AS TelefonoProfesional
		, P.PrimerNombre + ' ' + P.SegundoNombre + ' ' +P.PrimerApellido + ' ' +  P.SegundoApellido AS NombrePaciente
		, E.TipoIdentificacion --AS TipoIdPaciente
		, E.NumeroIdentificacion AS NumIdPaciente
		, CONVERT(VARCHAR(24),P.FechaNacimiento,103) AS FechaNacPaciente
		, E.Edad AS EdadPaciente
		--DIRECCIÓN DEL PACIENTE
		, DIR.Direccion AS DireccionSolicitante
		, D.Nombre AS CiudadPaciente
		, CUI.Nombre AS CiudadDireccionPaciente
		, P.Celular AS TelefonoPaciente
		, (select
		per.PrimerNombre + ' ' + per.PrimerApellido  
		from Persona per  INNER JOIN Padre pdr
		ON per.TipoIdentificacion= pdr.TipoIdentificacion and
			per.NumeroIdentificacion=pdr.NumeroIdentificacion
		INNER JOIN GrupoFamiliar grf
		ON per.TipoIdentificacion= grf.TipoIdentificacionMiembro and
		per.NumeroIdentificacion=grf.NumeroIdentificacionMiembro	
		where (pdr.TipoPadre = 'MA')
		and grf.IdFamilia = (select IdFamilia from GrupoFamiliar where NumeroIdentificacionMiembro = E.NumeroIdentificacion)
		AND GRF.FamiliaPrincipal = @FamiliaPrincipal) AS NombreResponsable
		--P.PrimerNombre + ' ' + P.PrimerApellido AS NombreResponsable
		,(select
		per.TipoIdentificacion  
		from Persona per  INNER JOIN Padre pdr
		ON per.TipoIdentificacion= pdr.TipoIdentificacion and
			per.NumeroIdentificacion=pdr.NumeroIdentificacion
		INNER JOIN GrupoFamiliar grf
		ON per.TipoIdentificacion= grf.TipoIdentificacionMiembro and
		per.NumeroIdentificacion=grf.NumeroIdentificacionMiembro	
		where (pdr.TipoPadre = 'MA')
		and grf.IdFamilia = (select IdFamilia from GrupoFamiliar where NumeroIdentificacionMiembro = E.NumeroIdentificacion)
		AND GRF.FamiliaPrincipal = @FamiliaPrincipal) AS TipoIdResponsable
		-- P.TipoIdentificacion AS TipoIdResponsable
		, (select
		per.NumeroIdentificacion  
		from Persona per  INNER JOIN Padre pdr
		ON per.TipoIdentificacion= pdr.TipoIdentificacion and
			per.NumeroIdentificacion=pdr.NumeroIdentificacion
		INNER JOIN GrupoFamiliar grf
		ON per.TipoIdentificacion= grf.TipoIdentificacionMiembro and
		per.NumeroIdentificacion=grf.NumeroIdentificacionMiembro	
		where (pdr.TipoPadre = 'MA')
		and grf.IdFamilia = (select IdFamilia from GrupoFamiliar where NumeroIdentificacionMiembro = E.NumeroIdentificacion)
		AND GRF.FamiliaPrincipal = @FamiliaPrincipal) AS NumIdResponsable
		-- P.NumeroIdentificacion AS NumIdResponsable
		--DIRECCIÓN DEL RESPONSABLE
		--CIUDAD DEL RESPONSABLE
		, (select
		per.Celular  
		from Persona per  INNER JOIN Padre pdr
		ON per.TipoIdentificacion= pdr.TipoIdentificacion and
			per.NumeroIdentificacion=pdr.NumeroIdentificacion
		INNER JOIN GrupoFamiliar grf
		ON per.TipoIdentificacion= grf.TipoIdentificacionMiembro and
		per.NumeroIdentificacion=grf.NumeroIdentificacionMiembro	
		where (pdr.TipoPadre = 'MA')
		and grf.IdFamilia = (select IdFamilia from GrupoFamiliar where NumeroIdentificacionMiembro = E.NumeroIdentificacion)
		AND GRF.FamiliaPrincipal = @FamiliaPrincipal) AS TelefonoResponsable	
		--P.Celular AS TelefonoResponsable
		, E.NombreAcompananteTraslado AS NombreAcompananteTraslado
		, E.TelefonoAcompananteTraslado AS TelefonoAcompananteTraslado
		, @NombreRolProfesional  AS NombreRolProfesional---, PER.PrimerNombre + ' ' + PER.SegundoNombre + ' ' + PER.PrimerApellido + ' ' +  PER.SegundoApellido AS NombreProfesional
		, PER.Celular AS TelProfesional
		, E.ServicioSolicitaReferencia AS ServicioSolicitaReferencia
		, CASE
			WHEN E.EstAspectoGeneral = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstAspectoGeneral = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstAspectoGeneral = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstAspectoGeneral = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstAspectoGeneral)
		  END AS EstadoAspectoGeneral
		, E.ObsAspectoGeneral AS ObservAspectoGeneral
		, CASE
			WHEN E.EstPielAnexos = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstPielAnexos = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstPielAnexos = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstPielAnexos = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstPielAnexos)
		  END AS EstadoPielAnexos
		, E.ObsPielAnexos AS ObservPielAnexos
		, CASE
			WHEN E.EstCabeza = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstCabeza = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstCabeza = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstCabeza = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstCabeza)
		  END AS EstadoCabeza
		, E.ObsCabeza AS ObservCabeza
		, CASE
			WHEN E.EstOjos = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstOjos = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstOjos = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstOjos = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstOjos)
		  END AS EstadoOjos
		, E.ObsOjos AS ObservOjos
		, CASE
			WHEN E.EstOidos = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstOidos = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstOidos = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstOidos = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstOidos)
		  END AS EstadoOidos
		, E.ObsOidos AS ObservOidos
		, CASE
			WHEN E.EstNariz = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstNariz = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstNariz = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstNariz = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstNariz)
		  END AS EstadoNariz
		, E.ObsNariz AS ObservNariz
		, CASE
			WHEN E.EstBocaFaringe = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstBocaFaringe = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstBocaFaringe = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstBocaFaringe = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstBocaFaringe)
		  END AS EstadoBocaFaringe
		, E.ObsBocaFaringe AS ObservBocaFaringe
		, CASE
			WHEN E.EstCuello = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstCuello = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstCuello = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstCuello = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstCuello)
		  END AS EstadoCuello
		, E.ObsCuello AS ObservCuello
		, CASE
			WHEN E.EstTorax = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstTorax = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstTorax = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstTorax = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstTorax)
		  END AS EstadoTorax
		, E.ObsTorax AS ObservTorax
		, CASE
			WHEN E.EstAbdomen = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstAbdomen = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstAbdomen = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstAbdomen = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstAbdomen)
		  END AS EstadoAbdomen
		, E.ObsAbdomen AS ObservAbdomen
		, CASE
			WHEN E.EstGenitales = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstGenitales = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstGenitales = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstGenitales = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstGenitales)
		  END AS EstadoGenitales
		, E.ObsGenitales AS ObservGenitales
		, CASE
			WHEN E.EstExtremidadesSuperiores = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstExtremidadesSuperiores = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstExtremidadesSuperiores = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstExtremidadesSuperiores = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstExtremidadesSuperiores)
		  END AS EstadoExtremSuperiores
		, E.ObsExtremidadesSuperiores AS ObservExtremSuperiores
		, CASE
			WHEN E.EstExtremidadesInferiores = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstExtremidadesInferiores = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstExtremidadesInferiores = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstExtremidadesInferiores = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstExtremidadesInferiores)
		  END AS EstadoExtremInferiores
		, E.ObsExtremidadesInferiores AS ObservExtremInferiores
		, CASE
			WHEN E.EstColumnaVertebral = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstColumnaVertebral = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstColumnaVertebral = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstColumnaVertebral = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstColumnaVertebral)
		  END AS EstadoColumnaVertebral
		, E.ObsColumnaVertebral AS ObservColumnaVertebral
		, CASE
			WHEN E.EstNeurologico = 'NR' THEN CONVERT(VARCHAR(30),'No Referenciado')
			WHEN E.EstNeurologico = 'NM' THEN CONVERT(VARCHAR(30),'Normal')
			WHEN E.EstNeurologico = 'NE' THEN CONVERT(VARCHAR(30),'No Explorado')
			WHEN E.EstNeurologico = 'AN' THEN CONVERT(VARCHAR(30),'Anormal')
			ELSE CONVERT(VARCHAR(30),E.EstNeurologico)
		  END AS EstadoNeurologico
		, E.ObsNeurologico AS ObservNeurologico
		, E.ImpresionDiagnostica AS ImpresionDiagnostica
		, E.TratamientoRealizado AS TratamientoRealizado
		, E.MotivoRemision AS MotivoRemision
		, E.ExamenFisicoReferencia As ExamenFisicoReferencia
		, @NombreUsuarioAutenticado AS NombreUsuarioAutenticado
		, @RegistroMedico  AS RegistroMedico
		, E.MotivoConsulta AS MotivoConsulta
	FROM Evolucion AS E
	INNER JOIN Persona AS P
	ON E.TipoIdentificacion = P.TipoIdentificacion
	AND E.NumeroIdentificacion = P.NumeroIdentificacion
	LEFT OUTER JOIN InformacionMedica AS IM
		ON P.TipoIdentificacion = IM.TipoIdentificacion
			AND P.NumeroIdentificacion = IM.NumeroIdentificacion
	LEFT OUTER JOIN Dominio AS DOM
		ON IM.IdEPS = DOM.Valor
			AND DOM.Dominio = 'EPS'
	LEFT OUTER JOIN Usuario AS U
		ON @NombreUsuarioAutenticado = U.userPrincipalName ---E.UsuarioCrea
	LEFT OUTER JOIN Persona AS PER
		ON U.userPrincipalName = PER.Username
	LEFT OUTER JOIN Empleado AS EMP
		ON PER.TipoIdentificacion = EMP.TipoIdentificacion
			AND PER.NumeroIdentificacion = EMP.NumeroIdentificacion
	LEFT OUTER JOIN Cargo AS CG
		ON EMP.Cargo = CG.IdCargo
	LEFT OUTER JOIN Contacto AS CON
		ON P.TipoIdentificacion = CON.TipoIdentificacion
		AND P.NumeroIdentificacion = CON.NumeroIdentificacion
	LEFT OUTER JOIN dbo.Departamento AS D
		ON P.IdDepartamento = D.Id
	LEFT OUTER JOIN dbo.GrupoFamiliar GRF 
		ON GRF.TipoIdentificacionMiembro = P.TipoIdentificacion 
		AND GRF.NumeroIdentificacionMiembro = P.NumeroIdentificacion
	LEFT OUTER JOIN dbo.Familia FAM
		ON FAM.IdFamilia = GRF.IdFamilia
	LEFT OUTER JOIN dbo.Direccion DIR 
		ON DIR.IdGrupoFamiliar = FAM.IdFamilia
	AND DIR.DireccionPrincipal = 1
	LEFT OUTER JOIN CIUDAD AS CUI 
		ON DIR.IdCiudad = CUI.Id

	WHERE E.Id = @IdEvolucion
	AND GRF.FamiliaPrincipal = @FamiliaPrincipal


END

