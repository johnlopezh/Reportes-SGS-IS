/********************************************************************
NOMBRE:					dbo.PR_SGS_Rpt_PermisosDeSalidaMultiFecha.sql
DESCRIPCIÓN:			SP para la construcción del reporte Permisos de Salida
						del modulo de transporte
PARAMETRO ENTRADA:		@fP_Fechas = Fecha de Consulta para los permisos 
						de Salida.
RESULTADO:				Muestra el resumen de todos los permisos de salida para
						un día seleccionado.
CREACIÓN 
REQUERIMIENTO:			Reporte de Transporte
AUTOR:					Luisa Lamprea
EMPRESA:				Saint George´s School  
FECHA DE CREACIÓN:		2017-04-05
----------------------------------------------------------------------------
MODIFICACIÓN:			Se hace la adapatación de la consulta a SP 
AUTOR:					John Alberto López Hernández	
FECHA:					2017-04-05
****************************************************************************/
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_PermisosDeSalidaMultiFecha] 
	
		 @fP_Fechas DATETIME
		,@idP_Seccion VARCHAR (max)

AS
BEGIN
/* Tabla Temporal para filtrar por curso */
DECLARE @Seccion TABLE 
	(
		IdSeccion VARCHAR (max)

	)
INSERT INTO @Seccion
SELECT SEC.Valor 
FROM F_SGS_Split(@idP_Seccion, ',') AS SEC
SELECT  
	STUFF(
			(SELECT
			', ' +  FORMAT(FCR.fechaseleccionada, 'dd/MM/yyyy')

		FROM FechaCambioTransporte  AS FCR
		WHERE FCR.IdSolicitudTransporte = ST.IdSolicitudTransporte
		FOR XML PATH ('')),
		1,2, '')as FechasSeleccionadas
	,C.nombre AS Curso
	,P.PrimerApellido + ' ' + isnull(P.SegundoApellido,'') + ' ' + 	P.PrimerNombre + ' ' + isnull(P.SegundoNombre,'') AS Nombre
	,FORMAT(ST.hora, N'hh\:mm') AS Hora
	,CONVERT(varchar(15),CAST(ST.hora AS TIME),100) AS Hora2
	,LOWER(RTRIM(SUBSTRING(ST.Observaciones,0, 215))) AS Observaciones
	,ST.NombreAutorizado + ' ( ' + ST.identificacionAutorizado + ' )' AS Autorizado
	,FORMAT(ST.FechaSolicitud, 'dd/MM/yyyy') AS FechaSolicitud 
	,ST.telefono AS Teléfono
	,EST.Descripcion  + '' + isnull(MR.Descripcion,'') AS Estado
	,PADRE.PrimerNombre + ' ' + isnull(PADRE.SegundoNombre,'') +  ' ' + PADRE.PrimerApellido + ' ( ' + ST.UsuarioLog + ' ) ' AS Padre
	,R.Descripcion AS Ruta

FROM SolicitudTransporte AS ST

	INNER JOIN TipoSolicitudTransporte AS TST 
	ON ST.idtiposolicitudtransporte = TST.idtiposolicitudtransporte

	INNER JOIN FechaCambioTransporte AS FCT
	ON FCT.IdSolicitudTransporte = ST.idsolicitudtransporte 
	AND FCT.FechaSeleccionada = @fP_Fechas

	INNER JOIN Persona AS P 
	ON P.NumeroIdentificacion = ST.IdentificacionSolicitante 
	AND P.TipoIdentificacion = ST.TipoIdentSolicitante

	INNER JOIN EstudianteCurso AS EC 
	ON P.NumeroIdentificacion = EC.NumeroIdentificacionEstudiante 
	AND P.TipoIdentificacion = EC.TipoIdentificacionEstudiante
	
	INNER JOIN Curso AS C 
	ON C.IdCurso = EC.IdCurso 

	INNER JOIN Nivel AS NVL
	ON C.IdNivel = NVL.IdNivel

	INNER JOIN Seccion AS SECC
	ON NVL.IdSeccion = SECC.IdSeccion

	INNER JOIN PeriodoLectivo AS PL 
	ON PL.AnioActivo = 1 
	AND PL.Id = C.AnioAcademico

	INNER JOIN Persona AS PADRE 
	ON PADRE.Username = ST.usuariolog

	INNER JOIN Dominio AS EST 
	ON EST.Dominio = 'EstadoSolicitud' 
	AND ST.EstadoSolicitud = EST.Valor

	INNER JOIN PersonaRuta AS PR 
	ON PR.NumeroIdentificacionPasajero = P.NumeroIdentificacion 
	AND PR.TipoIdentificacionPasajero = P.TipoIdentificacion 
	AND PR.Estado = 'Activo' 

	INNER JOIN BusRuta AS BR 
	ON BR.IdBusRuta = PR.idbusruta 
	AND BR.DominioJornada = '21' 
	AND BR.FechaCalendario = '19000101'

	INNER JOIN Dominio AS R
	ON R.Dominio = 'Ruta' 
	AND R.Valor = BR.DominioNombreRuta

	INNER JOIN @Seccion AS TSEC
	ON SECC.IdSeccion = TSEC.IdSeccion

	LEFT JOIN Dominio AS MR 
	ON MR.Dominio = 'MotivoRechazo' 
	AND CAST (ST.MotivoRechazo AS Varchar) = MR.Valor


WHERE 
	TST.IdTipoSolicitudTransporte in (29,30)
END

