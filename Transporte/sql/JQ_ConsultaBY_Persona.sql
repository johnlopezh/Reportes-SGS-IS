/*
NOMBRE: CONSULTA DE BASE DE YOGOURT POR PERSONA 
FECHA: 28/04/2016
AUTOR: JOHN L�PEZ & LUISA LAMPREA
*/

SELECT 
	 PRIMERAPELLIDO + SEGUNDOAPELLIDO AS APELLIDOS
	,PRIMERNOMBRE + SEGUNDONOMBRE AS NOMBRES
	,DOMINIONOMBRERUTA
	,J.DESCRIPCION AS JORNADA
	,ESTADO
	,FECHACALENDARIO AS FECHA
FROM PERSONARUTA AS PR WITH (NOLOCK)
JOIN PERSONA AS PER  WITH (NOLOCK)
	ON PR.NUMEROIDENTIFICACIONPASAJERO = PER.NUMEROIDENTIFICACION 
JOIN BUSRUTA AS BR WITH (NOLOCK)
	ON PR.IDBUSRUTA = BR.IDBUSRUTA AND PR.NUMEROIDENTIFICACIONPASAJERO = '52122333'
JOIN DOMINIO  AS J WITH(NOLOCK) 
	ON J.DOMINIO = 'JornadaTransporte' and J.VALOR = BR. DOMINIOJORNADA
ORDER BY FECHACALENDARIO ASC