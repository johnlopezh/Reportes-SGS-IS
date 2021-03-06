/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_ListadoAutorizaciones.sql
DESCRIPCIÓN:			Reporte que muestra el listado de estudiantes por nivel
						agrupado por curso, validando si esta o no en un grupo 
						de super tipo B
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

CREATE PROCEDURE [dbo].[PR_SGS_Rpt_ListadoAutorizaciones] 
		 @idP_Grupo INT ,
		 @sP_Estado VARCHAR (MAX)

AS
    BEGIN

		DECLARE @Estados TABLE(Estado VARCHAR(MAX));
		INSERT INTO @Estados
		SELECT SEC.Valor
		FROM F_SGS_Split(@sp_Estado, ',') AS SEC;

        SELECT 
			 CR.IdCurso
			,PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') AS NombreEstudiante
			,CR.Nombre AS Curso
			,ESC.NumeroIdentificacionEstudiante AS NumeroIdentificacionEstudiante
			,EST.CodigoEstudiante AS CodigoEstudiante
			,GES.IdGrupo AS IdGrupo
			,GES.EstudianteActivo AS Autorizado
			,GR.Nombre AS GrupoNombre
			,GR.FechaInicio AS Fecha
			,NV.Nombre AS Nivel
        FROM 	
		GrupoEstudiante AS GES
             INNER JOIN GRUPO AS GR ON 
			 GES.IdGrupo = GR.Id        
			 AND  GR.Id = @idP_Grupo 
			 INNER JOIN @Estados AS TES ON
				TES.Estado = GES.EstudianteActivo
	         INNER JOIN PeriodoLectivo AS PL ON 
				PL.AnioActivo = 1
             INNER JOIN Curso AS CR ON 
			 	CR.AnioAcademico = PL.Id 
			 INNER JOIN EstudianteCurso AS ESC ON
				GES.TipoIdentificacionEstudiante = ESC.TipoIdentificacionEstudiante
				AND GES.NumeroIdentificacionEstudiante = ESC.NumeroIdentificacionEstudiante
				AND CR.IdCurso = ESC.IdCurso 
		    INNER JOIN ESTUDIANTE AS EST ON
				GES.TipoIdentificacionEstudiante = EST.TipoIdentificacion 
			 AND GES.NumeroIdentificacionEstudiante = EST.NumeroIdentificacion
			 INNER JOIN Nivel AS NV ON CR.IdNivel = NV.IdNivel
             INNER JOIN Seccion AS SEC ON NV.IdSeccion = SEC.IdSeccion
			 INNER JOIN Persona AS PR ON
			 ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
			 AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion

		ORDER BY CR.IdNivel ASC, CR.IdCurso ASC, PR.PrimerApellido ASC
    END;


	
	

	