
DECLARE 
	-- @iP_Codigo BIGINT = NULL
	--,@sP_Nombre VARCHAR(350)= NULL
	--,@sP_Estado NVARCHAR(50) = NULL
	--,@iP_Nivel INT = NULL
	--,@iP_Curso INT = NULL
	--,@sP_Casa NVARCHAR(50)= NULL
	 @sP_Usuario VARCHAR(200) = 'nelson.robby@sgs.edu.co'
	,@sP_TipoRol VARCHAR(12) = 'DOC'
	,@PNombreEstudiante VARCHAR(200) = 'a'

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
	-- Deduce el tipo y número de identificación del usuario ingresado por parametro.
	****************************************************************************/

	SELECT
		 @TipoIdentificacionUsuario = P.TipoIdentificacion
		,@NumeroIdentificacionUsuario = P.NumeroIdentificacion
	FROM dbo.Usuario AS U WITH(NOLOCK)
	INNER JOIN dbo.Persona AS P WITH(NOLOCK)
		ON U.UserPrincipalName = P.Username
	WHERE U.userPrincipalName = @sP_Usuario;

	SELECT 
		@TipoRolUsuario = @sP_TipoRol

	SELECT @iP_AnioAcademico = (SELECT PE.Id FROM dbo.PeriodoLectivo AS PE WHERE PE.AnioActivo = 1);
	/****************************************************************************
	--CREACIÓN DE TABLA TEMPORAL QUE PERMITA ALMACENAR LA CONSULTA DE ESTUDIANTES
	****************************************************************************/
	DECLARE @TempConsultaEstudiantes TABLE 
	(
		 TipoIdentificacion VARCHAR(30) NULL
		,NumeroIdentificacion VARCHAR(50) NULL
		,IdCurso INT NULL
		,Nombre1 VARCHAR(200) NULL
		,Apellido VARCHAR(200) NULL
		,Curso VARCHAR(50) NULL
		,CodigoEstudiante BIGINT NULL
		,UrlFoto VARCHAR(100) NULL
		,Nombre VARCHAR(400) NULL
		,TipoDocumentoPadre VARCHAR(30) NULL
		,NumeroDocumentoPadre VARCHAR(50) NULL
		,TipoDocumentoMadre VARCHAR(30) NULL
		,NumeroDocumentoMadre VARCHAR(50) NULL
		,TipoDocumentoEstudiante VARCHAR(30) NULL
		,NumeroDocumentoEstudiante VARCHAR(50) NULL
		,TipoDocumentoDirectorGrupo VARCHAR(30) NULL
		,NumeroDocumentoDirectorGrupo VARCHAR(50) NULL
		,TipoDocumentoCoordinador VARCHAR(30) NULL
		,NumeroDocumentoCoordinador VARCHAR(50) NULL
	);
	/****************************************************************************
	--INSERCIÓN EN TABLA TEMPORAL PARA ALMACENAR LA CONSULTA DE ESTUDIANTES
	-- Consulta los estudiantes de un curso filtrando por un caracter ingresado
		por parametro.
	****************************************************************************/
	INSERT INTO @TempConsultaEstudiantes
	(TipoIdentificacion,NumeroIdentificacion, IdCurso,Nombre1,Apellido,Curso,CodigoEstudiante,UrlFoto
	,Nombre,TipoDocumentoPadre,NumeroDocumentoPadre,TipoDocumentoMadre,NumeroDocumentoMadre
	,TipoDocumentoEstudiante,NumeroDocumentoEstudiante,TipoDocumentoDirectorGrupo,NumeroDocumentoDirectorGrupo,
	TipoDocumentoCoordinador,NumeroDocumentoCoordinador)
	SELECT 
		 E.TipoIdentificacion AS TipoIdentificacion
		,E.NumeroIdentificacion AS NumeroIdentificacion
		,C.IdCurso AS IdCurso
		,CASE 
			WHEN P.SegundoNombre IS NULL THEN P.PrimerNombre 
			ELSE P.PrimerNombre + ' ' + P.SegundoNombre 
		 END AS Nombre
		,CASE 
			WHEN P.SegundoApellido IS NULL THEN P.PrimerApellido 
		 ELSE P.PrimerApellido + ' ' +  P.SegundoApellido 
		 END AS Apellido
		,C.Nombre AS Curso
		,E.CodigoEstudiante AS CodigoEstudiante
		,P.UrlFoto AS UrlFoto
		,(LTRIM(RTRIM(P.PrimerApellido + ' ' + ISNULL(LTRIM(RTRIM(P.SegundoApellido)),''))) + ' ' + LTRIM(RTRIM(P.PrimerNombre + ' ' + ISNULL(LTRIM(RTRIM(P.SegundoNombre)),''))))  AS Nombre
		,F.TipoDocumentoPadre AS TipoDocumentoPadre
		,F.NumeroDocumentoPadre AS NumeroDocumentoPadre
		,F.TipoDocumentoMadre AS TipoDocumentoMadre
		,F.NumeroDocumentoMadre AS NumeroDocumentoMadre
		,E.TipoIdentificacion AS TipoDocumentoEstudiante
		,E.NumeroIdentificacion AS NumeroDocumentoEstudiante
		,C.TipoDocumentoDirector AS TipoDocumentoDirectorGrupo
		,C.NumeroDocumentoDirector AS NumeroDocumentoDirectorGrupo
		,ES.TipoIdentificacionEmpleado AS TipoDocumentoCoordinador
		,ES.NumeroIdentificacionEmpleado AS NumeroDocumentoCoordinador
	FROM dbo.Persona AS P WITH(NOLOCK)
	INNER JOIN dbo.Estudiante AS E WITH(NOLOCK)
		ON P.TipoIdentificacion = E.TipoIdentificacion
			AND E.NumeroIdentificacion = P.NumeroIdentificacion
	INNER JOIN dbo.EstudianteCurso AS EC
		ON P.TipoIdentificacion = EC.TipoIdentificacionEstudiante 
			AND P.NumeroIdentificacion = EC.NumeroIdentificacionEstudiante
	INNER JOIN dbo.Curso AS C WITH(NOLOCK)
		ON EC.IdCurso = C.IdCurso
	INNER JOIN dbo.GrupoFamiliar AS GF WITH(NOLOCK)
		ON E.TipoIdentificacion = GF.TipoIdentificacionMiembro
			AND E.NumeroIdentificacion = GF.NumeroIdentificacionMiembro
	INNER JOIN dbo.Familia AS F WITH(NOLOCK)
		ON GF.IdFamilia = F.IdFamilia
	INNER JOIN dbo.Nivel AS N WITH(NOLOCK)
		ON C.IdNivel = N.IdNivel
	INNER JOIN dbo.Seccion AS S WITH(NOLOCK)
		ON N.IdSeccion = S.IdSeccion
	INNER JOIN dbo.EmpleadoSeccion AS ES WITH(NOLOCK)
		ON S.IdSeccion = ES.IdSeccion
	WHERE C.AnioAcademico = @iP_AnioAcademico
		--AND (E.CodigoEstudiante = @iP_Codigo OR  @iP_Codigo IS NULL)
		AND ((LTRIM(RTRIM(P.PrimerNombre + ' ' + ISNULL(LTRIM(RTRIM(P.SegundoNombre)),''))) + ' ' + LTRIM(RTRIM(P.PrimerApellido + ' ' + ISNULL(LTRIM(RTRIM(P.SegundoApellido)),'')))) 
			LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
		--AND (EC.Estado = @sP_Estado  OR @sP_Estado IS NULL)
		--AND (C.IdNivel = @iP_Nivel OR @iP_Nivel IS NULL)
		--AND (C.IdCurso = @iP_Curso OR @iP_Curso IS NULL)
		--AND (E.Casa = @sP_Casa OR @sP_Casa IS NULL)
		AND EC.Estado <> 'Retirado'
	GROUP BY
		 E.TipoIdentificacion
		,E.NumeroIdentificacion
		,C.IdCurso
		,CASE 
			WHEN P.SegundoNombre IS NULL THEN P.PrimerNombre 
			ELSE P.PrimerNombre + ' ' + P.SegundoNombre 
		 END
		,CASE 
			WHEN P.SegundoApellido IS NULL THEN P.PrimerApellido 
		 ELSE P.PrimerApellido + ' ' +  P.SegundoApellido 
		 END
		,C.Nombre
		,E.CodigoEstudiante
		,P.UrlFoto
		,(LTRIM(RTRIM(P.PrimerApellido + ' ' + ISNULL(LTRIM(RTRIM(P.SegundoApellido)),''))) + ' ' + LTRIM(RTRIM(P.PrimerNombre + ' ' + ISNULL(LTRIM(RTRIM(P.SegundoNombre)),''))))
		,F.TipoDocumentoPadre
		,F.NumeroDocumentoPadre
		,F.TipoDocumentoMadre
		,F.NumeroDocumentoMadre
		,E.TipoIdentificacion
		,E.NumeroIdentificacion
		,C.TipoDocumentoDirector
		,C.NumeroDocumentoDirector
		,ES.TipoIdentificacionEmpleado
		,ES.NumeroIdentificacionEmpleado
	ORDER BY
		 C.IdCurso ASC
		,CASE 
			WHEN P.SegundoApellido IS NULL THEN P.PrimerApellido 
		 ELSE P.PrimerApellido + ' ' +  P.SegundoApellido 
		 END ASC
		,CASE 
			WHEN P.SegundoNombre IS NULL THEN P.PrimerNombre 
			ELSE P.PrimerNombre + ' ' + P.SegundoNombre 
		 END ASC

	/****************************************************************************
	--VALIDACIÓN DE USUARIO Y ROL PARA FILTROS DE CONSULTA
	****************************************************************************/
	IF (@TipoRolUsuario = @TipoRolPadre)
	BEGIN
		SELECT 
			T.NumeroIdentificacion
			,T.Nombre
		FROM @TempConsultaEstudiantes AS T
		WHERE (T.TipoDocumentoPadre = @TipoIdentificacionUsuario
			AND T.NumeroDocumentoPadre = @NumeroIdentificacionUsuario)
			OR (T.TipoDocumentoMadre = @TipoIdentificacionUsuario
				AND T.NumeroDocumentoMadre = @NumeroIdentificacionUsuario)
			AND	((LTRIM(RTRIM(T.Apellido + ' ' + ISNULL(LTRIM(RTRIM(T.Nombre1)),'')))) 
		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	END
	IF (@TipoRolUsuario = @TipoRolEstudiante)
	BEGIN
		SELECT 
			T.NumeroIdentificacion
			,T.Nombre
		FROM @TempConsultaEstudiantes AS T
		WHERE T.TipoIdentificacion = @TipoIdentificacionUsuario
			AND T.NumeroIdentificacion = @NumeroIdentificacionUsuario
			AND	((LTRIM(RTRIM(T.Apellido + ' ' + ISNULL(LTRIM(RTRIM(T.Nombre1)),'')))) 
		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	END
	IF (@TipoRolUsuario = @TipoRolDocente)
	BEGIN
		SELECT DISTINCT
			T.NumeroIdentificacion
			,T.Nombre
		FROM @TempConsultaEstudiantes AS T
		INNER JOIN dbo.MateriaCurso AS MC WITH(NOLOCK)
			ON T.IdCurso = MC.IdCurso
				AND MC.TipoDocumentoProfesor = @TipoIdentificacionUsuario
				AND MC.NumeroDocumentoProfesor = @NumeroIdentificacionUsuario
				AND	((LTRIM(RTRIM(T.Apellido + ' ' + ISNULL(LTRIM(RTRIM(T.Nombre1)),'')))) 
		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	END
	IF (@TipoRolUsuario = @TipoRolDirector)
	BEGIN
		SELECT 
			T.NumeroIdentificacion
			,T.Nombre
		FROM @TempConsultaEstudiantes AS T
		WHERE T.TipoDocumentoDirectorGrupo = @TipoIdentificacionUsuario
			AND T.NumeroDocumentoDirectorGrupo = @NumeroIdentificacionUsuario
			AND	((LTRIM(RTRIM(T.Apellido + ' ' + ISNULL(LTRIM(RTRIM(T.Nombre1)),'')))) 
		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	END
	IF (@TipoRolUsuario = @TipoRolCoordinador)
	BEGIN
		SELECT 
			T.NumeroIdentificacion
			,T.Nombre
		FROM @TempConsultaEstudiantes AS T
		WHERE T.TipoDocumentoCoordinador = @TipoIdentificacionUsuario
			AND T.NumeroDocumentoCoordinador = @NumeroIdentificacionUsuario
			AND	((LTRIM(RTRIM(T.Apellido + ' ' + ISNULL(LTRIM(RTRIM(T.Nombre1)),'')))) 
		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	END
	IF (@TipoRolUsuario = @TipoRolVIP)
	BEGIN
		SELECT DISTINCT
			T.NumeroIdentificacion
			,T.Nombre
		FROM @TempConsultaEstudiantes AS T
		WHERE ((LTRIM(RTRIM(T.Apellido + ' ' + ISNULL(LTRIM(RTRIM(T.Nombre1)),'')))) 
		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	END
	IF (@TipoRolUsuario = @TipoRolNinguno)
	BEGIN
		SELECT
			'454545' AS NumeroIdentificacion
			,'hjhj' AS Nombre;
	END



	SELECT '454545' AS NumeroIdentificacion,'hjhj' AS Nombre;

	
	--DECLARE @PersonaTemp TABLE 
	--		(
	--				Nombre VARCHAR(240),
	--				NumeroIdentificacion VARCHAR(50)
	--		)

	--INSERT INTO @PersonaTemp
	--(Nombre,NumeroIdentificacion)
	--SELECT (LTRIM(RTRIM(PE.PrimerNombre + ' ' + ISNULL(LTRIM(RTRIM(PE.SegundoNombre)),''))) + ' ' + LTRIM(RTRIM(PE.PrimerApellido + ' ' + ISNULL(LTRIM(RTRIM(PE.SegundoApellido)),'')))) AS Nombre,
	--ES.NumeroIdentificacion 
	--FROM dbo.Persona AS PE
	--INNER JOIN dbo.Estudiante AS ES
	--ON ES.TipoIdentificacion = PE.TipoIdentificacion AND ES.NumeroIdentificacion = PE.NumeroIdentificacion
	--INNER JOIN dbo.EstudianteCurso AS ESCU
	--ON ESCU.TipoIdentificacionEstudiante = PE.TipoIdentificacion AND ESCU.NumeroIdentificacionEstudiante = PE.NumeroIdentificacion
	--INNER JOIN dbo.Curso AS CRS
	--ON CRS.IdCurso = ESCU.IdCurso
	--INNER JOIN dbo.PeriodoLectivo AS PL
	--ON PL.Id = CRS.AnioAcademico
	--WHERE ((LTRIM(RTRIM(PE.PrimerNombre + ' ' + ISNULL(LTRIM(RTRIM(PE.SegundoNombre)),''))) + ' ' + LTRIM(RTRIM(PE.PrimerApellido + ' ' + ISNULL(LTRIM(RTRIM(PE.SegundoApellido)),'')))) 
	--		LIKE '%' + @PNombreEstudiante + '%' COLLATE Modern_Spanish_CI_AI OR @PNombreEstudiante IS NULL)
	--		AND PL.AnioActivo = '1'
	--		AND ESCU.Estado <> 'Retirado'

	--SELECT Nombre, NumeroIdentificacion FROM @PersonaTemp WHERE Nombre IS NOT NULL

