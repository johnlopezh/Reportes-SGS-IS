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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_ConsultaGruposInvitacion]    Script Date: 6/18/2019 7:22:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE 
	[dbo].[PR_SGS_Rpt_ConsultaGruposInvitacion]    
		@id_Nivel   VARCHAR(MAX) 
AS   
BEGIN
		DECLARE @Niveles TABLE(IdNivel VARCHAR(MAX));
		INSERT INTO @Niveles
		SELECT SEC.Valor
		FROM F_SGS_Split(@id_Nivel, ',') AS SEC;

		SELECT DISTINCT
			   TP.Id AS IdTipoGrupo, 
			   GR.Id AS IdGrupo, 
			   TP.Nombre AS NombreTipoGrupo, 
			   GR.Nombre AS NombreGrupo, 
			   GR.FechaInicio
		FROM Grupo AS GR
			 INNER JOIN TipoGrupo AS TP ON GR.IdTipoGrupo = TP.Id
			 AND TP.TipoGrupoD = 'INV'
			 INNER JOIN PeriodoLectivo PL ON GR.FechaInicio BETWEEN PL.FechaInicioPeriodo AND PL.FechaFinPeriodo
											 AND PL.AnioActivo = 1
			 INNER JOIN GrupoNivel AS GV ON 
			 GR.Id = GV.IdGrupo 
			 
			 INNER JOIN @Niveles AS TNV ON 
			 TNV.IdNivel = GV.IdNivel

		ORDER BY GR.FechaInicio DESC;

END