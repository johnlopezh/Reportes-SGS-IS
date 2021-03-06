/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_SesionesGrupoEstudiantesSemana.sql
DESCRIPCIÓN:			Consulta que muestra los grupos en, que tiene un estudiante
						para un día de al semana, de muestran los 6 días de la semana.
CREACIÓN 
REQUERIMIENTO:			Reporte Grupos
AUTOR:					Luisa Lamprea 
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2016-06-25
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
----------------------------------------------------------------------------
MODIFICACION:			Se modifica la consulta para agregar los filtros de Seccion,
						Nivel, Curso, reporte modificado para Grupos 2.0
FECHA:					2019-06-25
REQUERIMIENTO:			Luisa Lamprea 
AUTOR:					John Alberto López 
****************************************************************************/
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_SesionesGrupoEstudiantesSemana] @dp_Fecha        DATE, 
                                                                  @Estudiante      VARCHAR(MAX), 
                                                                  @Seccion         VARCHAR(60), 
                                                                  @Nivel           VARCHAR(60), 
                                                                  @Curso           VARCHAR(60), 
                                                                  @SalidaEscolar   BIT, 
                                                                  @Refuerzo        BIT, 
                                                                  @Extracurricular BIT, 
                                                                  @Otros           BIT
AS
    BEGIN

        /* Prueba */
        /* Tabla Temporal para filtrar por Nombre */

        DECLARE @Nombre TABLE(IdNombre VARCHAR(MAX));
        INSERT INTO @Nombre
               SELECT NOM.Valor
               FROM F_SGS_Split(@Estudiante, ',') AS NOM;

/********************************************************************
Busca el lunes de la semana seleccionada. La semana comienza en Domingo
********************************************************************/

        DECLARE @d_Lunes DATE= DATEADD(d, 2 - DATEPART(weekday, @dP_Fecha), @dP_Fecha);

/********************************************************************
Consulta todos los estudiantes del año activo con su curso
********************************************************************/

        SELECT C.Nombre AS Curso, 
               P.PrimerApellido + ' ' + ISNULL(P.SegundoApellido, '') AS Apellidos, 
               P.PrimerNombre + ' ' + ISNULL(P.SegundoNombre, '') AS Nombres
               ,

/********************************************************************
Concatena todos los grupos con sesión el lunes
********************************************************************/

               ISNULL(STUFF(
        (
				
				SELECT  DISTINCT 
					', ' + GR.nombre 
				FROM GrupoEstudiante AS GE WITH (NOLOCK) 
				INNER JOIN GRUPO AS GR ON 
				GE.IdGrupo = GR.Id

				INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON
				GR.IdTipoGrupo = TG.Id

				INNER JOIN GrupoEstudianteSesion AS GES WITH (NOLOCK) ON
				GE.Id = GES.IdGrupoEstudiante


				INNER JOIN Sesion AS SES WITH (NOLOCK) ON
				GES.IdSesion = SES.Id
				AND SES.Fecha =  @d_Lunes

            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND ((TG.Refuerzo = @Refuerzo
                        AND @Refuerzo = 1)
                       OR (TG.SalidaEscolar = @SalidaEscolar
                           AND @SalidaEscolar = 1)
                       OR (TG.Extracurricular = @Extracurricular
                           AND @Extracurricular = 1)
                       OR IIF(TG.Refuerzo = 0
                              AND TG.SalidaEscolar = 0
                              AND TG.Extracurricular = 0, 1, 0) = @Otros
                       AND @Otros = 1) FOR XML PATH('')
        ), 1, 1, ''), '') AS Lunes
        ,

/********************************************************************
Concatena todos los grupos con sesión el martes
********************************************************************/

               ISNULL(STUFF(
        (
				SELECT  DISTINCT 
					', ' + GR.nombre 
				FROM GrupoEstudiante AS GE WITH (NOLOCK) 
				INNER JOIN GRUPO AS GR ON 
				GE.IdGrupo = GR.Id

				INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON
				GR.IdTipoGrupo = TG.Id

				INNER JOIN GrupoEstudianteSesion AS GES WITH (NOLOCK) ON
				GE.Id = GES.IdGrupoEstudiante


				INNER JOIN Sesion AS SES WITH (NOLOCK) ON
				GES.IdSesion = SES.Id
				AND SES.Fecha =  DATEADD(d, 1, @d_Lunes)
            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND ((TG.Refuerzo = @Refuerzo
                        AND @Refuerzo = 1)
                       OR (TG.SalidaEscolar = @SalidaEscolar
                           AND @SalidaEscolar = 1)
                       OR (TG.Extracurricular = @Extracurricular
                           AND @Extracurricular = 1)
                       OR IIF(TG.Refuerzo = 0
                              AND TG.SalidaEscolar = 0
                              AND TG.Extracurricular = 0, 1, 0) = @Otros
                       AND @Otros = 1) FOR XML PATH('')
        ), 1, 1, ''), '') AS Martes
        ,

/********************************************************************
Concatena todos los grupos con sesión el miercoles
********************************************************************/

               ISNULL(STUFF(
        (
				SELECT  DISTINCT 
					', ' + GR.nombre 
				FROM GrupoEstudiante AS GE WITH (NOLOCK) 
				INNER JOIN GRUPO AS GR ON 
				GE.IdGrupo = GR.Id

				INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON
				GR.IdTipoGrupo = TG.Id

				INNER JOIN GrupoEstudianteSesion AS GES WITH (NOLOCK) ON
				GE.Id = GES.IdGrupoEstudiante


				INNER JOIN Sesion AS SES WITH (NOLOCK) ON
				GES.IdSesion = SES.Id
				AND SES.Fecha =  DATEADD(d, 2, @d_Lunes)
            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND ((TG.Refuerzo = @Refuerzo
                        AND @Refuerzo = 1)
                       OR (TG.SalidaEscolar = @SalidaEscolar
                           AND @SalidaEscolar = 1)
                       OR (TG.Extracurricular = @Extracurricular
                           AND @Extracurricular = 1)
                       OR IIF(TG.Refuerzo = 0
                              AND TG.SalidaEscolar = 0
                              AND TG.Extracurricular = 0, 1, 0) = @Otros
                       AND @Otros = 1) FOR XML PATH('')
        ), 1, 1, ''), '') AS Miercoles
        ,

/********************************************************************
Concatena todos los grupos con sesión el jueves
********************************************************************/

               ISNULL(STUFF(
        (
				SELECT  DISTINCT 
					', ' + GR.nombre 
				FROM GrupoEstudiante AS GE WITH (NOLOCK) 
				INNER JOIN GRUPO AS GR ON 
				GE.IdGrupo = GR.Id

				INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON
				GR.IdTipoGrupo = TG.Id

				INNER JOIN GrupoEstudianteSesion AS GES WITH (NOLOCK) ON
				GE.Id = GES.IdGrupoEstudiante


				INNER JOIN Sesion AS SES WITH (NOLOCK) ON
				GES.IdSesion = SES.Id
				AND SES.Fecha =  DATEADD(d, 3, @d_Lunes)
            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND ((TG.Refuerzo = @Refuerzo
                        AND @Refuerzo = 1)
                       OR (TG.SalidaEscolar = @SalidaEscolar
                           AND @SalidaEscolar = 1)
                       OR (TG.Extracurricular = @Extracurricular
                           AND @Extracurricular = 1)
                       OR IIF(TG.Refuerzo = 0
                              AND TG.SalidaEscolar = 0
                              AND TG.Extracurricular = 0, 1, 0) = @Otros
                       AND @Otros = 1) FOR XML PATH('')
        ), 1, 1, ''), '') AS Jueves
        ,

/********************************************************************
Concatena todos los grupos con sesión el viernes
********************************************************************/

               ISNULL(STUFF(
        (
				SELECT  DISTINCT 
					', ' + GR.nombre 
				FROM GrupoEstudiante AS GE WITH (NOLOCK) 
				INNER JOIN GRUPO AS GR ON 
				GE.IdGrupo = GR.Id

				INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON
				GR.IdTipoGrupo = TG.Id

				INNER JOIN GrupoEstudianteSesion AS GES WITH (NOLOCK) ON
				GE.Id = GES.IdGrupoEstudiante


				INNER JOIN Sesion AS SES WITH (NOLOCK) ON
				GES.IdSesion = SES.Id
				AND SES.Fecha =  DATEADD(d, 4, @d_Lunes)
            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND ((TG.Refuerzo = @Refuerzo
                        AND @Refuerzo = 1)
                       OR (TG.SalidaEscolar = @SalidaEscolar
                           AND @SalidaEscolar = 1)
                       OR (TG.Extracurricular = @Extracurricular
                           AND @Extracurricular = 1)
                       OR IIF(TG.Refuerzo = 0
                              AND TG.SalidaEscolar = 0
                              AND TG.Extracurricular = 0, 1, 0) = @Otros
                       AND @Otros = 1) FOR XML PATH('')
        ), 1, 1, ''), '') AS Viernes
        ,

/********************************************************************
Concatena todos los grupos con sesión el sabado
********************************************************************/

               ISNULL(STUFF(
        (
				SELECT  DISTINCT 
					', ' + GR.nombre 
				FROM GrupoEstudiante AS GE WITH (NOLOCK) 
				INNER JOIN GRUPO AS GR ON 
				GE.IdGrupo = GR.Id

				INNER JOIN TipoGrupo AS TG WITH(NOLOCK) ON
				GR.IdTipoGrupo = TG.Id

				INNER JOIN GrupoEstudianteSesion AS GES WITH (NOLOCK) ON
				GE.Id = GES.IdGrupoEstudiante


				INNER JOIN Sesion AS SES WITH (NOLOCK) ON
				GES.IdSesion = SES.Id
				AND SES.Fecha =  DATEADD(d, 5, @d_Lunes)
            WHERE GE.numeroidentificacionestudiante = E.NumeroIdentificacion
                  AND GE.TipoIdentificacionEstudiante = E.TipoIdentificacion
                  AND ((TG.Refuerzo = @Refuerzo
                        AND @Refuerzo = 1)
                       OR (TG.SalidaEscolar = @SalidaEscolar
                           AND @SalidaEscolar = 1)
                       OR (TG.Extracurricular = @Extracurricular
                           AND @Extracurricular = 1)
                       OR IIF(TG.Refuerzo = 0
                              AND TG.SalidaEscolar = 0
                              AND TG.Extracurricular = 0, 1, 0) = @Otros
                       AND @Otros = 1) FOR XML PATH('')
        ), 1, 1, ''), '') AS Sabado
        FROM Estudiante AS E
             INNER JOIN PeriodoLectivo AS PL WITH(NOLOCK) ON PL.AnioActivo = 1
             INNER JOIN dbo.Persona AS P WITH(NOLOCK) ON E.TipoIdentificacion = P.TipoIdentificacion
                                                         AND E.NumeroIdentificacion = P.NumeroIdentificacion
                                                         AND E.TipoIdentificacion = P.TipoIdentificacion
             INNER JOIN dbo.Curso AS C WITH(NOLOCK) ON C.AnioAcademico = PL.Id
             INNER JOIN dbo.EstudianteCurso AS EC WITH(NOLOCK) ON E.TipoIdentificacion = EC.TipoIdentificacionEstudiante
                                                                  AND E.NumeroIdentificacion = EC.NumeroIdentificacionEstudiante
                                                                  AND EC.IdCurso = C.IdCurso
             INNER JOIN @Nombre AS TNOM ON P.NumeroIdentificacion = TNOM.IdNombre

        ORDER BY P.PrimerApellido + ' ' + ISNULL(P.SegundoApellido, ''), 
                 P.PrimerNombre + ' ' + ISNULL(P.SegundoNombre, '');
    END;