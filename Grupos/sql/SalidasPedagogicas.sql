
/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2012 (11.0.5676)
    Source Database Engine Edition : Microsoft SQL Server Standard Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [SGS_DES];
GO

/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_SalidaPedagogicaConsultaPrincipal]    Script Date: 6/6/2019 10:34:09 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_SalidaPedagogicaConsultaPrincipal.sql
DESCRIPCIÓN:			Reporte que muestra el listado de estudiantes por nivel
						agrupado por curso, validando si esta o no en un grupo.
CREACIÓN 
REQUERIMIENTO:			Reporte Grupos
AUTOR:					John Alberto López Hernández
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2017-12-12
----------------------------------------------------------------------------
MODIFICACION: no incluir en el reporte estudiantes retirados			 
FECHA:					2018-04-20
REQUERIMIENTO:			Error reportado por Patricia Tobar
AUTOR:					Luisa Lamprea
----------------------------------------------------------------------------
MODIFICACION: Incluir nombre del grupo			 
FECHA:					2018-04-20
REQUERIMIENTO:			Error reportado por Patricia Tobar
AUTOR:					Luisa Lamprea
****************************************************************************/

ALTER PROCEDURE [dbo].[PR_SGS_Rpt_SalidaPedagogicaConsultaPrincipal] @idP_Grupo INT
AS
    BEGIN
        SELECT 
			GR.Id
			, ESC.TipoIdentificacionEstudiante
			, ESC.NumeroIdentificacionEstudiante
			, GES.EstudianteActivo AS Autorizado
			, PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') AS NombreEstudiante
			, GR.Nombre
			, GR.FechaInicio AS Fecha
			, CR.IdCurso
			, CR.Nombre
			, EST.CodigoEstudiante



        FROM GrupoEstudiante AS GES
             INNER JOIN GRUPO AS GR ON GES.IdGrupo = GR.Id
                                       AND GR.Id = @idP_Grupo
             INNER JOIN EstudianteCurso AS ESC ON GES.TipoIdentificacionEstudiante = ESC.TipoIdentificacionEstudiante
                                                  AND GES.NumeroIdentificacionEstudiante = GES.NumeroIdentificacionEstudiante
             INNER JOIN PeriodoLectivo AS PL ON PL.AnioActivo = 1
             INNER JOIN Curso AS CR ON ESC.IdCurso = CR.IdCurso
                                       AND PL.Id = CR.AnioAcademico
             INNER JOIN Nivel AS NV ON CR.IdNivel = NV.IdNivel
             INNER JOIN Seccion AS SEC ON NV.IdSeccion = SEC.IdSeccion
			 INNER JOIN Estudiante AS EST ON ESC.TipoIdentificacionEstudiante = EST.TipoIdentificacion AND ESC.NumeroIdentificacionEstudiante = ESC.NumeroIdentificacionEstudiante
             INNER JOIN Persona AS PR ON ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
                                         AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion
		WHERE 
			ESC.Estado <> 'Retirado'
		ORDER BY CR.IdCurso, NombreEstudiante

    END;


