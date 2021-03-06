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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_AutorizacionSalidaEstudiantesNombre]    Script Date: 1/21/2019 11:36:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:					PR_SGS_Rpt_AutorizacionSalidaEstudiantesMultiFechaNombre
DESCRIPCIÓN:			SP para la construcción del reporte Autorización
						Salida estudiants, busca todos los nombres
						para después listarlos en el parametro del repote.
CREACIÓN 
REQUERIMIENTO:			Reporte de Transporte
AUTOR:					John Alberto López
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2018-01-29

--------------------------------------------------------------------------
MODIFICACIÓN:			Se agrega DISNTINCT en el Select para que en el 
						parametro solo muestre un estudiante.
FECHA:					2018-08-29
****************************************************************************/
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_AutorizacionSalidaEstudiantesMultiFechaNombre] 
	
		 @fP_Fechas DATETIME
		,@idP_Seccion VARCHAR (max)
AS
BEGIN
/* Tabla Temporal para filtrar por curso */
DECLARE @Seccion TABLE 
	(
		IdSeccion VARCHAR (max)

	)
INSERT INTO @Seccion
SELECT SEC.Valor 
FROM F_SGS_Split(@idP_Seccion, ',') AS SEC
SELECT DISTINCT
	 P.NumeroIdentificacion AS NumeroIdentificacion
	,P.PrimerApellido + ' ' + isnull(P.SegundoApellido,'') + ' ' + 	P.PrimerNombre + ' ' + isnull(P.SegundoNombre,'') AS Nombre


FROM SolicitudTransporte AS ST

	INNER JOIN TipoSolicitudTransporte AS TST 
	ON ST.idtiposolicitudtransporte = TST.idtiposolicitudtransporte

	INNER JOIN FechaCambioTransporte AS FCT
	ON FCT.IdSolicitudTransporte = ST.idsolicitudtransporte 
	AND FCT.FechaSeleccionada = @fP_Fechas

	INNER JOIN Persona AS P 
	ON P.NumeroIdentificacion = ST.IdentificacionSolicitante 
	AND P.TipoIdentificacion = ST.TipoIdentSolicitante

	INNER JOIN EstudianteCurso AS EC 
	ON P.NumeroIdentificacion = EC.NumeroIdentificacionEstudiante 
	AND P.TipoIdentificacion = EC.TipoIdentificacionEstudiante
	
	INNER JOIN Curso AS C 
	ON C.IdCurso = EC.IdCurso 

	INNER JOIN Nivel AS NVL
	ON C.IdNivel = NVL.IdNivel

	INNER JOIN Seccion AS SECC
	ON NVL.IdSeccion = SECC.IdSeccion

	INNER JOIN PeriodoLectivo AS PL 
	ON PL.AnioActivo = 1 
	AND PL.Id = C.AnioAcademico

	INNER JOIN Persona AS PADRE 
	ON PADRE.Username = ST.usuariolog

	INNER JOIN Dominio AS EST 
	ON EST.Dominio = 'EstadoSolicitud' 
	AND ST.EstadoSolicitud = EST.Valor

	INNER JOIN PersonaRuta AS PR 
	ON PR.NumeroIdentificacionPasajero = P.NumeroIdentificacion 
	AND PR.TipoIdentificacionPasajero = P.TipoIdentificacion 
	AND PR.Estado = 'Activo' 

	INNER JOIN BusRuta AS BR 
	ON BR.IdBusRuta = PR.idbusruta 
	AND BR.DominioJornada = '21' 
	AND BR.FechaCalendario = '19000101'

	INNER JOIN Dominio AS R
	ON R.Dominio = 'Ruta' 
	AND R.Valor = BR.DominioNombreRuta

	INNER JOIN @Seccion AS TSEC
	ON SECC.IdSeccion = TSEC.IdSeccion

WHERE 
	TST.IdTipoSolicitudTransporte in (29,30)

	ORDER BY Nombre ASC
END


