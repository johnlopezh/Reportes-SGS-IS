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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_CircularOpenday]    Script Date: 6/10/2019 7:55:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************
NOMBRE:				dbo.PR_SGS_Rpt_CircularOpenday.sql
AUTOR:				Luisa Lamprea
EMPRESA:			Colegio San Jorge de Inglaterra
FECHA CREACIÓN:		08/03/2018
PARÁMETROS ENTRADA: 	 
					 @PEstudiante
					,@idP_FechaInicio 
					,@idP_FechaFin 
						
EXCEPCIONES:		No Aplica
-----------------------------------------------
MODIFICACION:	06/12/2018
*********************************************************************/
ALTER PROCEDURE 
	 [dbo].[PR_SGS_Rpt_CircularOpenday] 	 	
		@iP_idAgendas VARCHAR (200)		
AS
BEGIN
DECLARE @agendas TABLE 
	(
		IdAgenda INT
	)
INSERT INTO @agendas
SELECT RT.Valor AS AG
FROM F_SGS_Split(@iP_idAgendas, ',') AS RT


select a.nombre
, p.primerNombre  +  isNull(' ' +  p.SegundoNombre,'')  as NombreEstudiante
, p.PrimerApellido +  isNull(' ' + p.SegundoApellido,'')  as ApellidoEstudiante
, Left (Convert (DATE , Cit.INICIO,111) ,10) as fecha
, Right(Convert (VARCHAR(20), Cit.inicio,0),7)  as inicio
, Right(Convert (VARCHAR(20), Cit.fin,0),7)  as fin
 ,FORMAT( GETDATE(), 'MMMM, yyyy', 'es-ES') AS FechaGeneracion
,LA.AGENDAMIENTOAUTOMATICO 
from Convocatoria Con
inner join @agendas Asel on Asel.idAgenda = Con.idAgenda
inner join agenda A on A.id = Con.idAgenda
inner join persona p on Con.Numeroidentificacion = p.numeroIdentificacion and Con.tipoIdentificacion = p.tipoidentificacion 
Left join Cita Cit on Con.Numeroidentificacion = Cit.numeroIdentificacion and COn.tipoIdentificacion = Cit.tipoidentificacion and Con.idagenda = Cit.idagenda
left join LogAgendamiento LA on LA.IdCita = Cit.Id
where LA.AgendamientoAutomatico = 1
order by A.id, ApellidoEstudiante

END