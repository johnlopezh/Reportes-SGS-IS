/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_ReteachingRefuerzoAC.sql
DESCRIPCIÓN:			Reporte que muaestra todos los comentarios de un 
						Estudiante en un refuerzo academico. 
RESULTADO:				Listado con las siguientes columnas: 
						Nombre del Estudiante, Curso, Refuerzo 
CREACIÓN 
REQUERIMIENTO:			Reportes de Grupos
AUTOR:					John Alberto López Hernández
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2017-05-2016

****************************************************************************/
CREATE PROCEDURE 

	 [dbo].[PR_SGS_Rpt_ReteachingRefuerzoAC] 

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




