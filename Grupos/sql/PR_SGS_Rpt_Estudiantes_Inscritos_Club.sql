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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_Estudiantes_Inscritos_Club]    Script Date: 8/20/2019 10:59:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_Estudiantes_Inscritos_Club.sql
DESCRIPCIÓN:			Consulta que muestra los grupos en, que tiene un estudiante
						para un día de al semana, de muestran los 6 días de la semana.
CREACIÓN 
REQUERIMIENTO:			Reporte Grupos
AUTOR:					
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2016-06-25
---------------------------------------------------------------------------
MODIFICACION:			Se modifica la consulta para agregar los filtros de Seccion,
						Nivel, Curso, reporte modificado para Grupos 2.0
FECHA:					2019-06-25
REQUERIMIENTO:			Luisa Lamprea 
AUTOR:					John Alberto López 
****************************************************************************/

ALTER PROCEDURE [dbo].[PR_SGS_Rpt_Estudiantes_Inscritos_Club] @Nivel VARCHAR(MAX), 
                                                              @Curso VARCHAR(MAX)
AS
    BEGIN

        DECLARE @Cursos TABLE(IdCurso VARCHAR(MAX));
        INSERT INTO @Cursos
               SELECT NOM.Valor
               FROM F_SGS_Split(@Curso, ',') AS NOM;
        DECLARE @NoInscritos BIT= 0;
        SELECT C.Nombre AS Curso, 
               C.IdCurso AS IdCurso, 
               P.PrimerApellido + ' ' + ISNULL(P.SegundoApellido, '') AS Apellidos, 
               P.PrimerNombre + ' ' + ISNULL(P.SegundoNombre, '') AS Nombres, 
               ISNULL(STUFF(
        (
            SELECT DISTINCT 
                   ', ' + GR.nombre
            FROM GrupoEstudiante AS GE WITH(NOLOCK)
                 INNER JOIN GRUPO AS GR ON GE.IdGrupo = GR.Id
                 INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON GR.IdTipoGrupo = TG.Id
                 INNER JOIN GrupoEstudianteSesion AS GES WITH(NOLOCK) ON GE.Id = GES.IdGrupoEstudiante
            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND TG.TipoGrupoD = 'AUTE'
                  AND TG.Categoria = 'TipoClub' FOR XML PATH('')
        ), 1, 1, ''), 'No inscrito') AS Club
        FROM Estudiante AS E
             INNER JOIN PeriodoLectivo AS PL WITH(NOLOCK) ON PL.AnioActivo = 1
             INNER JOIN dbo.Persona AS P WITH(NOLOCK) ON E.TipoIdentificacion = P.TipoIdentificacion
                                                         AND E.NumeroIdentificacion = P.NumeroIdentificacion
                                                         AND E.TipoIdentificacion = P.TipoIdentificacion
             INNER JOIN dbo.Curso AS C WITH(NOLOCK) ON C.AnioAcademico = PL.Id
             INNER JOIN dbo.EstudianteCurso AS EC WITH(NOLOCK) ON E.TipoIdentificacion = EC.TipoIdentificacionEstudiante
                                                                  AND E.NumeroIdentificacion = EC.NumeroIdentificacionEstudiante
                                                                  AND EC.IdCurso = C.IdCurso
             INNER JOIN @Cursos AS TNOM ON C.IdCurso = TNOM.IdCurso

        ORDER BY P.PrimerApellido + ' ' + ISNULL(P.SegundoApellido, ''), 
                 P.PrimerNombre + ' ' + ISNULL(P.SegundoNombre, '');
    END;