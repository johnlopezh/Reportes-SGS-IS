/************************************************************************        
NOMBRE DEL PROGRAMA:	PR_SGS_Rpt_InscritosGrupos    
DESCRIPCIÓN:			Reportes de Estudiantes Inscritos a Grupos por Día   
						Devuelve un listado de todos los grupos en los que está inscrito 
						un estudiante en una fecha dada.
PARÁMETROS DE ENTRADA:  @dP_FechaInicio: Rango Incial a consultar
						@dP_FechaFin: Rango Final a Consultar. 
						@Estudiante VARCHAR (max): Números de identificación. 
PARÁMETROS DE SALIDA:   No aplica.  
RESULTADO:				Listado con las siguientes columnas: 
						Seccion, Nivel, Curso, Apellidos, Nombres, Grupo, FechaInicio, 
						FechaFin, Profesor,Estado
						La consulta se entrega ordenada alfabéticamente por apellidos y 
						nombres del estudiante y por nombre del grupo			
---------------------------------------------------------------------------  
CREACIÓN 
REQUERIMIENTO:			Grupos 2.0
AUTOR:					John Alberto López Hernández
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2019-06-03
****************************************************************************/

ALTER PROCEDURE [dbo].[PR_SGS_Rpt_InscritosGrupos] @dP_FechaInicio DATE, 
                                                   @dP_FechaFin    DATE, 
                                                   @Estudiante     VARCHAR(MAX)
AS
    BEGIN

        /* Tabla Temporal para filtrar por Nombre */

        DECLARE @Nombre TABLE(IdNombre VARCHAR(MAX));
        INSERT INTO @Nombre
               SELECT NOM.Valor
               FROM F_SGS_Split(@Estudiante, ',') AS NOM;
		/* Consulta Principal */
        SELECT G.Id AS Id, 
               EST.PrimerApellido + ' ' + ISNULL(EST.SegundoApellido, '') AS ApellidoEstudiante, 
               ISNULL(EST.PrimerNombre, '') + ' ' + ISNULL(EST.SegundoNombre, '') AS NombreEstudiante, 
               CR.Nombre AS Curso, 
               NV.Nombre AS Nivel, 
               SEC.Nombre AS Seccion, 
               G.IdTipoGrupo AS IdTipoGrupo, 
               G.Nombre AS Grupo, 
               CONVERT(VARCHAR(15), CAST(G.FechaInicio AS DATE), 100) AS FechaInicio, 
               CONVERT(VARCHAR(15), CAST(G.FechaFin AS DATE), 100) AS FechaFin, 
               ISNULL(P.PrimerNombre, '') + ' ' + ISNULL(P.SegundoNombre, '') + ' ' + P.PrimerApellido + ' ' + ISNULL(P.SegundoApellido, '') AS ResponsableGrupo, 
               GPE.EstudianteActivo AS EstadoEstudiante
        FROM dbo.Grupo AS G WITH(NOLOCK)
             INNER JOIN dbo.TipoGrupo AS TP WITH(NOLOCK) ON G.IdTipoGrupo = TP.Id
             INNER JOIN GrupoEstudiante AS GPE WITH(NOLOCK) ON GPE.IdGrupo = G.Id
             INNER JOIN dbo.Empleado AS E WITH(NOLOCK) ON G.TipoIdentificacionEmpleado = E.TipoIdentificacion
                                                          AND G.NumeroIdentificacionEmpleado = E.NumeroIdentificacion
             INNER JOIN dbo.Persona AS P WITH(NOLOCK) ON E.TipoIdentificacion = P.TipoIdentificacion
                                                         AND E.NumeroIdentificacion = P.NumeroIdentificacion
             INNER JOIN dbo.Persona AS EST WITH(NOLOCK) ON GPE.NumeroIdentificacionEstudiante = EST.NumeroIdentificacion
             INNER JOIN EstudianteCurso AS ESC WITH(NOLOCK) ON GPE.TipoIdentificacionEstudiante = ESC.TipoIdentificacionEstudiante
                                                               AND GPE.NumeroIdentificacionEstudiante = ESC.NumeroIdentificacionEstudiante
             INNER JOIN Curso AS CR WITH(NOLOCK) ON ESC.IdCurso = CR.IdCurso
             INNER JOIN PeriodoLectivo AS PL ON PL.Id = CR.AnioAcademico
                                                AND PL.AnioActivo = 1
             INNER JOIN Nivel AS NV WITH(NOLOCK) ON CR.IdNivel = NV.IdNivel
             INNER JOIN Seccion AS SEC WITH(NOLOCK) ON NV.IdSeccion = SEC.IdSeccion
             INNER JOIN @Nombre AS TNOM ON EST.NumeroIdentificacion = TNOM.IdNombre
        WHERE(G.FechaInicio <= @dP_FechaFin
              AND G.FechaFin >= @dP_FechaInicio)
        GROUP BY G.Id, 
                 G.IdTipoGrupo, 
                 G.Nombre, 
                 G.FechaInicio, 
                 G.FechaFin, 
                 G.Estado, 
                 P.PrimerNombre, 
                 P.SegundoApellido, 
                 P.PrimerApellido, 
                 P.SegundoNombre, 
                 EST.PrimerNombre, 
                 EST.SegundoApellido, 
                 EST.PrimerApellido, 
                 EST.SegundoNombre, 
                 GPE.EstudianteActivo, 
                 CR.Nombre, 
                 NV.Nombre, 
                 SEC.Nombre
        ORDER BY EST.PrimerApellido ASC, 
                 EST.PrimerNombre ASC, 
                 G.FechaInicio DESC;
    END;