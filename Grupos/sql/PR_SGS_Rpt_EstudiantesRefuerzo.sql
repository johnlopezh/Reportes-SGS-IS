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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_EstudiantesRefuerzo]    Script Date: 11/29/2017 2:56:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_EstudiantesRefuerzo.sql
DESCRIPCIÓN:			Listado de los estudiants que asistieron a refuerzos 
						Para un periodolectivo seleccionado. 
RESULTADO:				Listado con las siguientes columnas: 
						Nombre del Estudiante, Curso, Refuerzo 
CREACIÓN 
REQUERIMIENTO:			Reportes de Grupos
AUTOR:					John Alberto López Hernández
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2017-05-2016
----------------------------------------------------------------------------
MODIFICACIÓN:			Se agregar el parametro PeriodoLectivo
						Para solo se muestren los grupos del tipo refuerzo del 
						año seleccionado. 
AUTOR:					John Alberto López
FECHA:					2017-11-30
****************************************************************************/
ALTER PROCEDURE 
	 [dbo].[PR_SGS_Rpt_EstudiantesRefuerzo] 

	 /* Espacio Parametros */

		  @idP_Seccion VARCHAR (max)
		, @idp_Nivel VARCHAR(max)
		, @PeriodoLectivo VARCHAR(20) = 2017

AS
BEGIN
/* Tabla Temporal para filtrar por curso */
DECLARE @Niveles TABLE 
	(
		IdNivelSeccionado varchar(60)
	)
INSERT INTO @Niveles
SELECT NV.Valor 
FROM F_SGS_Split(@idp_Nivel, ',') AS NV

SELECT 
	 PR.PrimerApellido + ' ' + isnull (PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + isnull (PR.SegundoNombre, '') AS NombreCompleto 
	,CR.Nombre AS Curso
	,GR.Nombre AS Refuerzo
	,PR.Username AS CorreoElectronico
	,PL.Descripcion AS PeriodoLectivo
	,CONVERT(VARCHAR(12),GR.FechaInicio,103) AS FechaInicioGrupo
    ,CONVERT(VARCHAR(12),GR.FechaFin,103) AS FechaFinGrupo
FROM GRUPOESTUDIANTE  AS GE

	INNER JOIN GRUPO AS GR 
	ON  GR.Id = GE.IdGrupo

	INNER JOIN PERSONA AS PR
	ON GE.TipoIdentificacionEstudiante = PR.TipoIdentificacion
	AND GE.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion

	INNER JOIN EstudianteCurso as ESC
	ON GE.TipoIdentificacionEstudiante = ESC.TipoIdentificacionEstudiante
	AND GE.NumeroIdentificacionEstudiante = ESC.NumeroIdentificacionEstudiante
	AND ESC.Estado <> 'Retirado'

	INNER JOIN Curso AS CR
	ON ESC.IdCurso = CR.IdCurso

	INNER JOIN PeriodoLectivo AS PL
	ON  CR.AnioAcademico = PL.Id
	AND GR.FechaInicio BETWEEN PL.FechaInicioPeriodo AND PL.FechaFinPeriodo
	
	INNER JOIN Nivel AS NV
	ON CR.IdNivel = NV.IdNivel

	INNER JOIN Seccion AS SEC
	ON NV.IdSeccion = SEC.IdSeccion

	INNER JOIN @Niveles AS NVS
	ON NV.IdNivel = NVS.IdNivelSeccionado

WHERE GR.IdTipoGrupo = 13 AND PL.AnioInicial = @PeriodoLectivo

ORDER BY CR.idcurso ASC, PR.PrimerApellido ASC, GR.FechaInicio ASC
END




