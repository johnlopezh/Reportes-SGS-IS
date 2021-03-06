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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_AutorizacionSalidaEstudiantes]    Script Date: 8/29/2018 1:27:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_AutorizacionSalidaEstudiantes.sql
DESCRIPCIÓN:			SP para la construcción del reporte Autorización 
						Salida Estudiantes.

RESULTADO:				Muestra el resumen de todos los permisos de salida para
						un día seleccionado.
CREACIÓN 
REQUERIMIENTO:			Reporte de Transporte
AUTOR:					John Alberto López
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2018-29-01

MODIFICACIÓN:			Se agrega al SELECT el ID de solicitud de transporte
						para agrupar en el reporte por Id Solicitud

****************************************************************************/
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_AutorizacionSalidaEstudiantes] 
	
		 @fP_Fechas DATETIME
		,@idP_Seccion VARCHAR (max)
		,@idP_NombreEstudiante VARCHAR (max)

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

/* Tabla Temporal para filtrar por Nombre */
DECLARE @Nombre TABLE 
	(
		IdNombre VARCHAR (max)
	)
INSERT INTO @Nombre
SELECT NOM.Valor 
FROM F_SGS_Split(@idP_NombreEstudiante, ',') AS NOM

SELECT  
	 FORMAT(fct.fechaseleccionada, 'dd/MM/yyyy') AS FechaSeleccionada
	,C.nombre AS Curso
	,P.PrimerApellido + ' ' + isnull(P.SegundoApellido,'') + ' ' + 	P.PrimerNombre + ' ' + isnull(P.SegundoNombre,'') AS Nombre
	,CONVERT(varchar(15),CAST(ST.hora AS TIME),100) AS Hora
	,REPLACE(LOWER(RTRIM(SUBSTRING(ST.Observaciones,0, 200))),char(10),' ' ) AS Observaciones
	,UPPER(ST.NombreAutorizado) + ' ( ' + ST.identificacionAutorizado + ' )' AS Autorizado
	,FORMAT(ST.FechaSolicitud, 'dd/MM/yyyy') AS FechaSolicitud 
	,ST.telefono AS Teléfono
	,EST.Descripcion  + '' + isnull(MR.Descripcion,'') AS Estado
	,PADRE.PrimerNombre + ' ' + isnull(PADRE.SegundoNombre,'') +  ' ' + PADRE.PrimerApellido + ' ( ' + ST.UsuarioLog + ' ) ' AS Padre
	,R.Descripcion AS Ruta
	,ST.IdSolicitudTransporte AS IdSolicitudTransporte

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

	
	INNER JOIN @Nombre AS TNOM
	ON  P.NumeroIdentificacion = TNOM.IdNombre

	LEFT JOIN Dominio AS MR 
	ON MR.Dominio = 'MotivoRechazo' 
	AND CAST (ST.MotivoRechazo AS Varchar) = MR.Valor


WHERE 
	TST.IdTipoSolicitudTransporte in (1,14)


END
