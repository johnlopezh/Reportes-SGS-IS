/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2012 (11.0.5676)
    Source Database Engine Edition : Microsoft SQL Server Standard Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [SGS]
GO
/****** Object:  StoredProcedure [dbo].[PR_SGS_ConsultarRutaDiariaExtracurricular]    Script Date: 10/17/2017 11:39:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:				PR_SGS_ConsultarRutaDiariaExtracurricular.sql
DESCRPCIÓN:			Creación Strored Procedures "Consulta Ruta Completa"
AUTOR:				John Alberto López Hernández
REQUERIMIENTO:		SP35 - Transporte
EMPRESA:			Colegio San Jorge de Inglaterra
FECHA CREACIÓN:		18-08-2016
PARÁMETROS ENTRADA:	No Aplica
EXCEPCIONES:		No Aplica
---------------------------------------------------------------------
MODIFICACIÓN:		Se inserta el Paradero de la jornada Extracurricular
					Se hace el join con preruta se agrega campo dirección
					paradero.
AUTOR:				John Alberto López Hernández	
REQUERIMIENTO:		
FECHA MODIFICACIÓN:	10 de Octubre de 2017
********************************************************************/

ALTER PROCEDURE 
	[dbo].[PR_SGS_ConsultarRutaDiariaExtracurricular]    
(
	 @NumeroRuta VARCHAR(max) 
	,@Fecha DATETIME 
	,@Jornada VARCHAR(2) 
)
AS   
BEGIN
DECLARE @Rutas TABLE 
	(
		IdRuta VARCHAR(60)
	)

DECLARE @Consulta TABLE
	(
		 Id BIGINT IDENTITY
		,Nombre VARCHAR(403)
		,Curso VARCHAR(50)
		,Direccion VARCHAR(150)
		,DireccionParadero VARCHAR(150)
		,TelefonoDireccion VARCHAR(50)
		,CelularMadre VARCHAR(100)
		,CelularPadre VARCHAR(50)
		,NombreAuxiliar VARCHAR(max)
		,Estado VARCHAR(50)
		,NumeroDia INT NULL
		,IdSolicitudTransporte BIGINT NULL
		,Conductor VARCHAR(max)
		,Placa VARCHAR(8)
		,Capacidad INT
		,Celular VARCHAR(50)
		,DominioNombreRutaBY VARCHAR(60)
		,DominioNombreRutaPT VARCHAR(60)
		,Justificacion VARCHAR(500)
		,TotalRow BIGINT  NULL
		,EsNuevo BIT NULL
	)

INSERT INTO @Rutas
SELECT RT.Valor AS Fecha
FROM F_SGS_Split(@NumeroRuta, ',') AS RT

INSERT INTO @Consulta
SELECT 
	  PER.Nombre AS Nombre
	, PER.Curso AS Curso
	, DR.Direccion +' '+ DR.Barrio +' '+ DR.DescripcionDireccion AS Direccion 
	, PreRu.DireccionParadero AS DireccionParadero
	, PER.TelefonoDireccion AS TelefonoDireccion
	, PER.CelularMadre AS CelularMadre
	, PER.CelularPadre AS CelularPadre
	, ASIS.PrimerApellido + ' ' + asis.SegundoApellido + ' ' + asis.PrimerNombre + ' ' + asis.SegundoNombre AS NombreAuxiliar
	, PRBY.Estado AS Estado
	, CAL.NumeroDia AS NumeroDia
	, PRBY.IdSolicitudTransporte AS IdSolicitudTransporte
	, B.NombreConductor + ' ' + b.ApellidoConductor AS Conductor
	, B.Placa as Placa
	, B.Puestos AS Capacidad
	, B.Celular	AS Celular
	, BRBY.DominioNombreRuta AS Ruta
    , BRPT.DominioNombreRuta AS Plantilla
	, isNull(PRBY.Justificacion,'') AS Justificacion  
	, NULL AS TotalRuta
	, 0 AS EsNuevo

FROM 
	PERSONARUTA AS PRBY
    INNER JOIN BUSRUTA AS BRBY ON 
		PRBY.IDBUSRUTA = BRBY.IDBUSRUTA
			--AND PRBY.Estado = 'Activo' 
	INNER JOIN PERSONARUTA  AS PRPT ON
			PRPT.Estado = 'Activo'
		AND PRBY.TipoIdentificacionPasajero = PRPT.TipoIdentificacionPasajero
	    AND PRBY.NumeroIdentificacionPasajero = PRPT.NumeroIdentificacionPasajero
	INNER JOIN BUSRUTA AS BRPT ON 
		PRPT.IdBusRuta = BRPT.IdBusRuta
		AND BRPT.DominioJornada = BRBY.DominioJornada
		AND BRPT.FechaCalendario = '19000101' 
	LEFT JOIN PreRuta AS PreRu ON
		PRPT.IdPersonaRuta = PreRu.IdPersonaRuta
	INNER JOIN VW_DATOSPERSONA AS PER ON
		PRPT.NumeroIdentificacionPasajero = PER.NumeroIdentificacion 
		AND PRPT.TipoIdentificacionPasajero = PER.TipoIdentificacion
	LEFT JOIN  Direccion as DR ON 
		PRBY.IdDireccion= DR.IdDireccion 
	INNER JOIN CALENDARIO AS CAL ON
		CAL.fecha = BRBY.FechaCalendario
	INNER  JOIN PERSONA AS ASIS ON 
		ASIS.TipoIdentificacion = BRBY.TipoIdentificacionAsistente and 
		ASIS.NumeroIdentificacion = BRBY.NumeroIdentificacionAsistente
	INNER JOIN BUS AS B ON
		B.Idbus =  BRBY.Idbus
WHERE 
		BRBY.FechaCalendario = @Fecha 
	AND BRBY.DominioJornada =  @Jornada
	AND BRBY.DominioNombreRuta IN (SELECT * FROM @Rutas) 

ORDER BY 
	 BRBY.DominioNombreRuta,
	 idcurso asc


UPDATE @Consulta 
SET TotalRow  = (	SELECT COUNT(id) 
					FROM @Consulta AS C 					
					WHERE C.DominioNombreRutaBY = CON.DominioNombreRutaBY
					GROUP BY C.DominioNombreRutaBY
				)
FROM @Consulta AS CON
SELECT 
* 
FROM 
@Consulta

END


exec PR_SGS_ConsultarRutaDiariaExtracurricular @NumeroRuta=N'52',@Jornada=N'22',@Fecha='2017-10-18 00:00:00'