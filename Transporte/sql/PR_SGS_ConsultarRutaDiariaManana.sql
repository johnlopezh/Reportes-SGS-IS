/********************************************************************
NOMBRE:				dbo.PR_SGS_ConsultarRutaDiaria.sql
DESCRPCIÓN:			Creación Strored Procedures "Consulta Ruta Diaria Manaña"
					este SP Consulta los estudiantes de una ruta para una 
					fecha determinada en la jornada de la tarde, este SP 
					se ejecuta en el SP PR_SGS_Rpt_RutaDiaria, para llenar 
					la tabla temporal, se agrego como indicador una columna 
					llamado Jornada con el valor de 1 para identificar la 
					jornada tarde y poder filtral en el SSRS.
AUTOR:				John Alberto López Hernández
REQUERIMIENTO:		SP35 - Transporte
EMPRESA:			Colegio San Jorge de Inglaterra
FECHA CREACIÓN:		18-08-2016
PARÁMETROS ENTRADA:	@NumeroRuta (Permite seleccionar varias al tiempo)
					@Fecha fecha a consultar
EXCEPCIONES:		No Aplica
---------------------------------------------------------------------
MODIFICACIÓN: 
AUTOR: 
REQUERIMIENTO:  
EMPRESA: Saint George's School
FECHA MODIFICACIÓN: 
********************************************************************/
ALTER PROCEDURE 
	[dbo].[PR_SGS_ConsultarRutaDiariaManana]    
(
	 @NumeroRuta VARCHAR(max) 
	,@Fecha DATETIME 
)
AS   
BEGIN
/* Variable para calcula la siguiente fecha donde el estudiante tiene clase */

DECLARE  @SiguienteFecha DATE = (Select min(FECHA) FROM calendario WHERE Fecha > @Fecha and tipodia like 'E-%')
/* Tabla Temporal para recibir rutas y dividirlas */
DECLARE @Rutas TABLE 
	(
		IdRuta VARCHAR(60)
	)
INSERT INTO @Rutas
SELECT RT.Valor AS Fecha
FROM F_SGS_Split(@NumeroRuta, ',') AS RT
/* Consulta Principal */
SELECT 
	  PER.Nombre AS Nombre
	, PER.Curso AS Curso
	, DR.Direccion +' '+ DR.DescripcionDireccion AS Direccion 
	, PER.TelefonoDireccion AS TelefonoDireccion
	, PER.CelularMadre AS CelularMadre
	, PER.CelularPadre AS CelularPadre
	, PRE.direccionparadero AS Paradero
	, CONVERT(varchar(15),CAST(pre.Hora AS TIME),100)  AS Hora
	, ASIS.PrimerApellido + ' ' + asis.SegundoApellido + ' ' + asis.PrimerNombre + ' ' + asis.SegundoNombre AS NombreAuxiliar
	, PRTHOY.Estado AS Estado
	, CAL.NumeroDia AS NumeroDia
	, ISNULL(PRTHOY.IdSolicitudTransporte, 0) AS IdSolicitudTransporte
	, B.NombreConductor + ' ' + b.ApellidoConductor AS Conductor
	, B.Placa as Placa
	, B.Puestos AS Capacidad
	, B.Celular	AS Celular
	, PRE.Orden AS NumeroParadero
	, BTHOY.DominioNombreRuta AS Ruta
    , BTUSAL.DominioNombreRuta AS Plantilla
	, (CASE WHEN PRTHOY.Justificacion IS null then ' ' else PRTHOY.Justificacion END) AS Justificación
	, NULL AS TotalRow
	, RR.IdRuta AS RutaReporte
	, TST.Temporal AS Temporal
	, 2 AS Jornada
	, @SiguienteFecha AS SiguienteFecha
	, PRTUSAL.IdDireccion AS IdDirecionUsal
	, PRTHOY.IdDireccion AS IdDirecionHoy
FROM 
	PERSONARUTA AS PRTHOY 
		INNER JOIN BUSRUTA AS BTHOY 
		  ON PRTHOY.IdBusRuta = BTHOY.IdBusRuta
		  AND PRTHOY.Estado = 'Activo'
		INNER JOIN PERSONARUTA AS PRTUSAL
		   ON PRTHOY.TipoIdentificacionPasajero = PRTUSAL.TipoIdentificacionPasajero
		   AND PRTHOY.NumeroIdentificacionPasajero = PRTUSAL.NumeroIdentificacionPasajero
		INNER JOIN BUSRUTA AS BTUSAL 
			ON PRTUSAL.IdBusRuta = BTUSAL.IdBusRuta
		  AND PRTUSAL.Estado = 'Activo'
		INNER JOIN VW_DATOSPERSONA AS PER ON
			PRTHOY.NumeroIdentificacionPasajero = PER.NumeroIdentificacion and 
			PRTHOY.TipoIdentificacionPasajero = PER.TipoIdentificacion
		LEFT JOIN PRERUTA AS PRE ON
			PRTUSAL.IdPersonaRuta = PRE.IdPersonaRuta
		INNER JOIN  Direccion as DR ON 
			PRTHOY.IdDireccion= DR.IdDireccion 
		INNER JOIN CALENDARIO AS CAL ON
			CAL.fecha = BTUSAL.FechaCalendario
		INNER JOIN PERSONA AS ASIS ON 
			ASIS.TipoIdentificacion = BTHOY.TipoIdentificacionAsistente and 
			ASIS.NumeroIdentificacion = BTHOY.NumeroIdentificacionAsistente
		INNER JOIN BUS AS B ON
			B.Idbus =  BTHOY.Idbus
		INNER JOIN @Rutas AS RR ON 
			BTHOY.DominioNombreRuta = RR.IdRuta 
			OR BTUSAL.DominioNombreRuta = RR.IdRuta	
		LEFT JOIN SolicitudTransporte AS ST ON
			PRTHOY.IdSolicitudTransporte = ST.IdSolicitudTransporte
		LEFT JOIN TipoSolicitudTransporte AS TST ON
			ST.IdTipoSolicitudTransporte = TST.IdTipoSolicitudTransporte
WHERE 
	BTUSAL.FechaCalendario = '19000101'
		AND BTUSAL.DominioJornada = '11' 
		AND BTHOY.FechaCalendario = @SiguienteFecha
		AND BTHOY.DominioJornada like '11'
ORDER BY 
	 CAST(RR.IdRuta as int) ASC
	 -- LL: este ordenamiento garantiza que el primer registro siempre corresponde a un pasajero que va en
	 -- la ruta y puede ser utlizado para los encabezados del reporte
	 ,ABS(CAST (RR.IdRuta as int) - CAST (BTHOY.DominioNombreRuta as int)) 
	,NumeroParadero
END
