/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2012 (11.0.5676)
    Source Database Engine Edition : Microsoft SQL Server Standard Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [SGS_DES]
GO
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_SalidaPedagogicaConsultaPrincipal]    Script Date: 6/7/2019 10:08:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

ALTER PROCEDURE [dbo].[PR_SGS_Rpt_SalidaPedagogicaConsultaPrincipal] 
		  @id_Nivel VARCHAR(MAX)
		 ,@idP_Grupo INT  

AS
    BEGIN
	    DECLARE @Nivel TABLE(IdNivel VARCHAR(MAX));
        INSERT INTO @Nivel
               SELECT NOM.Valor
               FROM F_SGS_Split(@id_Nivel, ',') AS NOM;
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
			,NV.
        FROM 	
		GrupoEstudiante AS GES
             INNER JOIN GRUPO AS GR ON 
			 GES.IdGrupo = GR.Id        
			 AND  GR.Id = @idP_Grupo 
			 INNER JOIN TipoGrupo AS TG ON
				GR.IdTipoGrupo = Tg.Id
				AND TG.TipoGrupoD = 'INV'
	         INNER JOIN PeriodoLectivo AS PL ON 
				PL.AnioActivo = 1
			 INNER JOIN EstudianteCurso AS ESC ON
				GES.TipoIdentificacionEstudiante = ESC.TipoIdentificacionEstudiante
				AND GES.NumeroIdentificacionEstudiante = ESC.NumeroIdentificacionEstudiante
             INNER JOIN Curso AS CR ON 
			 	CR.AnioAcademico = PL.Id AND
				ESC.IdCurso = CR.IdCurso 
			 INNER JOIN ESTUDIANTE AS EST ON
				GES.TipoIdentificacionEstudiante = EST.TipoIdentificacion 
			 AND GES.NumeroIdentificacionEstudiante = EST.NumeroIdentificacion
			 INNER JOIN Nivel AS NV ON CR.IdNivel = NV.IdNivel
             INNER JOIN Seccion AS SEC ON NV.IdSeccion = SEC.IdSeccion
			 INNER JOIN Persona AS PR ON
			 ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
			 AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion
			INNER JOIN @Nivel AS TNIV ON NV.IdNivel = TNIV.IdNivel

		WHERE 
		
			 ESC.Estado <> 'Retirado'
    END;

	
	
	



