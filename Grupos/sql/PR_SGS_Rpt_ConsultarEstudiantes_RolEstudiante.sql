/*********************************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_ConsultarEstudiantes_RolEstudiante.sql
DESCRIPCIÓN:			Muestra los estudiantes con sus grupo, filtrado con curso
						preseleccionado. 
PARÁMETROS DE ENTRADA:	 @sP_AnioAcademico INT 
						,@sP_Codigo BIGINT = NULL
						,@sP_Nombre varchar(350)= NULL
						,@sP_Estado nvarchar(50) = NULL
						,@sP_Nivel INT = NULL
						,@sP_Curso INT = NULL
						,@sP_Casa nvarchar(50)= NULL
						,@sP_Usuario VARCHAR(200)
						,@sP_Rol INT
PARÁMETROS DE SALIDA:	No Aplica
EXCEPCIONES:			No Aplica
AUTOR:					Héctor Arias
REQUERIMIENTO:			Consulta filtrada de estudiantes
EMPRESA:				Colegio San Jorge de Inglaterra
FECHA CREACIÓN:			13-12-2018
----------------------------------------------------------------------------------
*********************************************************************************/

CREATE PROCEDURE [dbo].[PR_SGS_Rpt_ConsultarEstudiantes_RolEstudiante] 
(

	 @sP_Usuario VARCHAR(200) = NULL
	,@sP_TipoRol VARCHAR(12) = NULL
	,@Curso VARCHAR(MAX)
	,@PNombreEstudiante VARCHAR(MAX)

) AS BEGIN 

	/* Sacarlas Secciones Habilitadas */
	  DECLARE @Cursos TABLE(IdCurso VARCHAR(MAX));
	  INSERT INTO @Cursos
      SELECT CUR.Valor
      FROM F_SGS_Split(@Curso, ',') AS CUR;

	/****************************************************************************
	DECLARACIÓN DE VARIABLES GLOBALES
	****************************************************************************/
	DECLARE  @TipoIdentificacionUsuario VARCHAR(30)
			,@NumeroIdentificacionUsuario VARCHAR(50)
			,@TipoRolVIP VARCHAR(10) = 'VIP'
			,@TipoRolPadre VARCHAR(10) = 'PAD'
			,@TipoRolEstudiante VARCHAR(10) = 'EST'
			,@TipoRolDirector VARCHAR(10) = 'DIR'
			,@TipoRolCoordinador VARCHAR(10) = 'COO'
			,@TipoRolDocente VARCHAR(10) = 'DOC'
			,@TipoRolNinguno VARCHAR(10) = 'NAN'
			,@TipoRolUsuario VARCHAR(10)
			,@iP_AnioAcademico INT;
	/****************************************************************************
	--ASIGNACIÓN DE VALORES A LAS VARIABLES
	****************************************************************************/
	SELECT @iP_AnioAcademico = (SELECT PE.Id FROM dbo.PeriodoLectivo AS PE WHERE PE.AnioActivo = 1);

	SELECT
		 @TipoIdentificacionUsuario = P.TipoIdentificacion
		,@NumeroIdentificacionUsuario = P.NumeroIdentificacion
	FROM dbo.Usuario AS U WITH(NOLOCK)
	INNER JOIN dbo.Persona AS P WITH(NOLOCK)
		ON U.UserPrincipalName = P.Username
	WHERE U.userPrincipalName = @sP_Usuario;

	SELECT 
		@TipoRolUsuario = @sP_TipoRol

	IF (@TipoRolUsuario = @TipoRolVIP)
	BEGIN

	SELECT
		 ESC.TipoIdentificacionEstudiante
		,ESC.NumeroIdentificacionEstudiante
		,PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') AS NombreEstudiante
			
		FROM Nivel AS NV
		INNER JOIN Seccion AS SEC ON
		NV.IdSeccion = SEC.IdSeccion

		INNER JOIN Curso AS CR ON
		CR.AnioAcademico = @iP_AnioAcademico
		AND CR.IdNivel = NV.IdNivel
		
		INNER JOIN EstudianteCurso AS ESC 
		ON ESC.IdCurso = CR.IdCurso

		INNER JOIN Persona AS PR 
		ON ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
		AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion

		INNER JOIN @Cursos AS TCUR ON CR.IdCurso = TCUR.IdCurso
		WHERE PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') + ' ' + PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') LIKE '%' + replace(@PNombreEstudiante, ' ', '%') + '%' COLLATE Latin1_General_CI_AI
		ORDER BY PR.PrimerApellido ASC
	END
	IF (@TipoRolUsuario = @TipoRolCoordinador)
	BEGIN
		
		SELECT 
		ESC.TipoIdentificacionEstudiante
		,ESC.NumeroIdentificacionEstudiante
		,PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') AS NombreEstudiante
		
		FROM Nivel AS NV 
		INNER JOIN Seccion AS SEC ON 
			NV.IdSeccion = SEC.IdSeccion
		INNER JOIN EmpleadoSeccion AS ES ON
			ES.IdSeccion = SEC.IdSeccion
		AND ES.TipoIdentificacionEmpleado = @TipoIdentificacionUsuario
		AND ES.NumeroIdentificacionEmpleado = @NumeroIdentificacionUsuario

		INNER JOIN Curso AS CR ON
		CR.AnioAcademico = @iP_AnioAcademico
		AND CR.IdNivel = NV.IdNivel

		INNER JOIN EstudianteCurso AS ESC 
		ON ESC.IdCurso = CR.IdCurso

		INNER JOIN Persona AS PR 
		ON ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
		AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion
		WHERE PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') + ' ' + PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') LIKE '%' + replace(@PNombreEstudiante, ' ', '%') + '%' COLLATE Latin1_General_CI_AI

		ORDER BY PR.PrimerApellido ASC
	END

	IF (@TipoRolUsuario = @TipoRolDirector)	
	BEGIN
		SELECT 
			ESC.TipoIdentificacionEstudiante 
			,ESC.NumeroIdentificacionEstudiante
			,PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') AS NombreEstudiante
		FROM Curso AS CR
		INNER JOIN Nivel AS NV ON
		CR.IdNivel = NV.IdNivel
		AND CR.AnioAcademico = @iP_AnioAcademico 
		AND TipoDocumentoDirector = @TipoIdentificacionUsuario 
		AND CR. NumeroDocumentoDirector = @NumeroIdentificacionUsuario 
		INNER JOIN Seccion AS SEC ON
		NV.IdSeccion = SEC.IdSeccion
		INNER JOIN EstudianteCurso AS ESC ON
		ESC.IdCurso = CR.IdCurso

		INNER JOIN Persona AS PR 
		ON ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
		AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion
		WHERE PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') + ' ' + PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') LIKE '%' + replace(@PNombreEstudiante, ' ', '%') + '%' COLLATE Latin1_General_CI_AI

		ORDER BY PR.PrimerApellido ASC
	END

	IF (@TipoRolUsuario = @TipoRolPadre)
	BEGIN
		 
		SELECT 
			ESC.TipoIdentificacionEstudiante
			,ESC.NumeroIdentificacionEstudiante
			,PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') + ' ' + PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') AS NombreEstudiante
		  FROM GrupoFamiliar AS GF
		 INNER JOIN EstudianteCurso AS ESC ON
		ESC.TipoIdentificacionEstudiante = GF.TipoIdentificacionMiembro
		AND ESC.NumeroIdentificacionEstudiante = GF.NumeroIdentificacionMiembro
		INNER JOIN Curso AS CR ON
		ESC.IdCurso = CR.IdCurso 
		AND CR.AnioAcademico = @iP_AnioAcademico


		INNER JOIN Nivel AS NV ON
		CR.IdNivel = NV.IdNivel

		INNER JOIN Seccion AS SEC ON
		NV.IdSeccion = SEC.IdSeccion

		INNER JOIN Persona AS PR 
		ON ESC.TipoIdentificacionEstudiante = PR.TipoIdentificacion
		AND ESC.NumeroIdentificacionEstudiante = PR.NumeroIdentificacion

		 where IdFamilia = (SELECT 
			GF.IdFamilia
		FROM dbo.GrupoFamiliar AS GF WITH(NOLOCK)
			INNER JOIN dbo.Familia AS F WITH(NOLOCK)
			ON  GF.FamiliaPrincipal = 1 AND 
			GF.IdFamilia = F.IdFamilia
			AND GF.TipoIdentificacionMiembro = @TipoIdentificacionUsuario
		 AND  GF.NumeroIdentificacionMiembro = @NumeroIdentificacionUsuario)
		 AND  PR.PrimerNombre + ' ' + ISNULL(PR.SegundoNombre, '') + ' ' + PR.PrimerApellido + ' ' + ISNULL(PR.SegundoApellido, '') LIKE '%' + replace(@PNombreEstudiante, ' ', '%') + '%' COLLATE Latin1_General_CI_AI

		ORDER BY  PR.PrimerApellido ASC
	END

END