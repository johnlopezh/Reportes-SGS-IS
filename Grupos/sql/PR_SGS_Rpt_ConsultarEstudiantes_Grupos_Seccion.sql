/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_ConsultarEstudiantes_Grupos_Seccion.sql
DESCRIPCIÓN:			Consulta que muestra las secciones que tiene habilitada 
						un tipo de rol especifico. Se habilito para los siguientes
						tipos de rol: VIP, Padre, Director de Grupo, Coordinador
CREACIÓN 
REQUERIMIENTO:			Reporte Grupos
AUTOR:					JOHN ALBERTO LÓPEZ HERNÁNDEZ
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2019-06-17
----------------------------------------------------------------------------
******************************************************************************/
CREATE PROCEDURE [dbo].[PR_SGS_Rpt_ConsultarEstudiantes_Grupos_Seccion] 
(
	 @sP_Usuario VARCHAR(200) 
	,@sP_TipoRol VARCHAR(12)

)
AS
BEGIN

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

		/* Sacarlas Secciones Habilitadas */

		SELECT
				SEC.IdSeccion AS IdSeccion,
				SEC.Nombre AS NombreSeccion
			
		FROM Seccion AS SEC

	END
	IF (@TipoRolUsuario = @TipoRolCoordinador)
	BEGIN
	
		SELECT 
				ES.IdSeccion AS IdSeccion,
				SEC.Nombre AS NombreSeccion
		FROM EmpleadoSeccion AS ES
		INNER JOIN Seccion AS SEC ON
		ES.IdSeccion = SEC.IdSeccion 
		AND ES.TipoIdentificacionEmpleado = @TipoIdentificacionUsuario
		AND ES.NumeroIdentificacionEmpleado = @NumeroIdentificacionUsuario
		
	END

	IF (@TipoRolUsuario = @TipoRolDirector)	
	BEGIN
		SELECT 
				SEC.IdSeccion AS IdSeccion,
				SEC.Nombre AS NombreSeccion
		FROM Curso AS CR
		INNER JOIN Nivel AS NV ON
		CR.IdNivel = NV.IdNivel
		AND CR.AnioAcademico = @iP_AnioAcademico 
		AND TipoDocumentoDirector = @TipoIdentificacionUsuario 
		AND CR. NumeroDocumentoDirector = @NumeroIdentificacionUsuario 
		INNER JOIN Seccion AS SEC ON
		NV.IdSeccion = SEC.IdSeccion
	END

	IF (@TipoRolUsuario = @TipoRolPadre)
	BEGIN
		 
		 SELECT 
				SEC.IdSeccion AS IdSeccion,
				SEC.Nombre AS NombreSeccion

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
		 where IdFamilia = (SELECT 
			GF.IdFamilia
		FROM dbo.GrupoFamiliar AS GF WITH(NOLOCK)
			INNER JOIN dbo.Familia AS F WITH(NOLOCK)
			ON  GF.FamiliaPrincipal = 1 AND 
			GF.IdFamilia = F.IdFamilia
			AND GF.TipoIdentificacionMiembro = @TipoIdentificacionUsuario
		 AND  GF.NumeroIdentificacionMiembro = @NumeroIdentificacionUsuario)
		
	END
END