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
/****** Object:  StoredProcedure [dbo].[PR_SGS_Rpt_VehiculosRuta0]    Script Date: 8/2/2018 11:44:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************** 
NOMBRE:         dbo.PR_SGS_Rpt_VehiculosRuta0.sql 
DESCRIPCIÓN:    SP permite consultar los vehículos asignados a una familia 
                personas autorizadas y estudiantes autorizados, aquí se  
                aplana la información de estudiantes y personas autorizadas.  
RESULTADO:      Muestra la siguientes Columnas: 
				IdFamilia, PlacaVehiculo, MarcaLinea, Modelo, Color,
				UrlFotoHijo, PersonasAutorizadas, RutaCompleta, Descripcion
CREACIÓN  
REQUERIMIENTO:  Reportes de Transporte 
AUTOR:          Luisa Lamprea 
EMPRESA:        Saint George-s School   
FECHA DE CREACIÓN:    2018-04-20 
---------------------------------------------------------------------------- 
****************************************************************************/ 
ALTER PROCEDURE [dbo].[PR_SGS_Rpt_VehiculosRuta0] 
    @sP_Placa VARCHAR(20)
AS 
  BEGIN 
      DECLARE @sP_idEstudiante VARCHAR(20) = '0'

      -- Traer el URL de las Fotos 
      DECLARE @URLFotos VARCHAR (max) = (SELECT valor 
         FROM   parametro 
         WHERE  descripcion = 'URLfotos') 
      -- Crear una tabla con las plantillas de transporte de todas las personas 
      DECLARE @plantillas TABLE 
        ( 
           tipoidentificacion   VARCHAR (30), 
           numeroidentificacion VARCHAR (50), 
           rutaam               VARCHAR(30), 
           rutapm               VARCHAR(30) 
        ) 
      INSERT INTO @plantillas 
      /* Consulta para identificar los estudiantes que están en ruta 0 para un servicio */ 
      SELECT PRM.tipoidentificacionpasajero, 
             PRM.numeroidentificacionpasajero, 
             BRM.dominionombreruta, 
             BRT.dominionombreruta

      FROM   personaruta AS PRM 
             INNER JOIN busruta BRM 
                     ON BRM.idbusruta = PRM.idbusruta 
                        AND BRM.dominiojornada = '11' 
                        AND BRM.fechacalendario = '19000101' 
                        AND PRM.estado = 'Activo' 
             INNER JOIN personaruta PRT 
                     ON PRM.tipoidentificacionpasajero = 
                        PRT.tipoidentificacionpasajero 
                        AND PRM.numeroidentificacionpasajero = 
                            PRT.numeroidentificacionpasajero 
             INNER JOIN busruta BRT 
                     ON BRT.idbusruta = PRT.idbusruta 
                        AND BRT.dominiojornada = '21' 
                        AND BRT.fechacalendario = '19000101' 
                        AND PRT.estado = 'Activo' 
      WHERE  ( @sP_idEstudiante = '0' 
                OR @sP_idEstudiante = PRM.numeroidentificacionpasajero ) 

      -- Traer la información de Vehiculos 
      SELECT gf.idfamilia                            AS IdFamilia, 
             placavehiculo                           AS PlacaVehiculo, 
             Mar.nombre + ' ' + LV.nombre            AS MarcaLinea, 
             modelo, 
             color, 
             p.primernombre 
             + Isnull (' ' + p.segundonombre, '' ) + ' ' 
             + p.primerapellido 
             + Isnull (' ' + p.segundoapellido, '' ) AS NombreHijo, 
             NV.Nombre                                AS NivelHijo, 
             @URLFotos + p.urlfoto                   AS URLFotoHijo, 
             Stuff((SELECT ', ' + PA.primernombre 
                           + Isnull (' ' + PA.segundonombre, '' ) + ' ' 
                           + PA.primerapellido 
                           + Isnull (' ' + PA.segundoapellido, '' ) + ' (' 
                           + PA. tipoidentificacion + ' ' 
                           + PA.numeroidentificacion + ')' 
                    FROM   familiapersonaautorizada FPA 
                           INNER JOIN personaautorizada PA 
                                   ON PA.numeroidentificacion = 
                                      FPA.numeroidentificacionpa 
                                      AND PA.tipoidentificacion = 
                                          FPA.tipoidentificacionpa 
                    WHERE  FPA.idfamilia = GF.idfamilia 
                    FOR xml path('')), 1, 1, '')     AS PersonasAutorizadas, 
             IIF(RT.rutaam = RT.rutapm, 3, IIF(RT.rutaam = '0', 2 , 1))        AS TipoServicio, 
             PL.descripcion 
      FROM   familiavehiculo FV 
             INNER JOIN vehiculo AS VE 
                     ON FV.placavehiculo = VE.placa 
             INNER JOIN marca MAR 
                     ON MAR.id = VE.marca 
             INNER JOIN linea LV 
                     ON LV.idlinea = VE.linea 
                        AND LV.idmarca = VE.marca 
             INNER JOIN grupofamiliar GF 
                     ON GF.idfamilia = FV.idfamilia 
             INNER JOIN estudiantecurso EC 
                     ON EC.numeroidentificacionestudiante = 
                        GF.numeroidentificacionmiembro 
                        AND EC.tipoidentificacionestudiante = 
                            GF.tipoidentificacionmiembro 
             INNER JOIN curso C 
                     ON C.idcurso = EC.idcurso 
			 INNER JOIN Nivel AS NV
					 ON C.IdNivel = NV.IdNivel
             INNER JOIN periodolectivo PL 
                     ON PL.id = C.anioacademico 
                        AND PL.anioactivo = 1 
             INNER JOIN persona P 
                     ON EC.numeroidentificacionestudiante = 
                        p.numeroidentificacion 
                        AND EC.tipoidentificacionestudiante = 
                            P.tipoidentificacion 
             INNER JOIN @plantillas RT 
                     ON RT.numeroidentificacion = P.numeroidentificacion 
                        AND RT.tipoidentificacion = P.tipoidentificacion 
      WHERE  @sP_Placa = '0' 
              OR VE.placa = @sP_Placa 
      ORDER  BY P.PrimerApellido,
				P.SegundoApellido,
				/*GF.idfamilia, */
                VE.placa, 
                C.idcurso 
  END 



