Definir Funcao HTTP_POST();

Definir Funcao HTTP_CREATE();

Definir Alfa vHTTP;

Definir Alfa aApi;

Definir Alfa aPostData;

Definir Alfa aRetorno;

Definir Alfa aAccessToken;

Definir Alfa aMsgErro;

Definir Alfa aDatSis;

Definir Data dCmpRef;

Definir Alfa aEnter;

Definir Alfa aMens;

Definir Alfa aNumCad;

Definir Alfa aMensOld;

Definir Data eDatRef;

nUsaUTF8 = 1;

id = 1;

aAccessToken = "OTAyYTBmMmMxZjAwNDg2MWE4NTM0YmU5ZmMxYzA2ZWM6ZTI3MmY0NUVjRDExNDg3MmIzQTg3MzgxMjE4OGQ1YmQ=";

/*aApi = https://test-de-c1-1.apis.roche.com;*/

aApi = "https://test-de-c1-1.apis.roche.com/fg-pnc-employee-proc-roche3-test/v2/employees?offset=1&limit=50&countryIds=BR&bufferFlag=bufferOFF";

aPostData = "{\"username\": \"902a0f2c1f004861a8534be9fc1c06ec\",\"password\": \"e272f45EcD114872b3A873812188d5bd\"}";

/*TrocaString(aPostData,"*","\"",aPostData);*/

HTTP_POST();

Se(vCodigo = 200)
Inicio
	getJSONobj(aRetorno, "data", aRetorno);

	getJSONstring(aRetorno, "token", aRetorno);

	getJSONString(aRetorno, "access_token", aAccessToken);

	aAccessToken = "OTAyYTBmMmMxZjAwNDg2MWE4NTM0YmU5ZmMxYzA2ZWM6ZTI3MmY0NUVjRDExNDg3MmIzQTg3MzgxMjE4OGQ1YmQ=";

	aApi = "https://test-de-c1-1.apis.roche.com";

	aPostData = "{*type*: *general*,*month*: *" + aDatSis + "*,*search_type*: *staff*}";

	TrocaString(aPostData, "*", "\"", aPostData);

	HTTP_POST();

	Se(vCodigo = 200)
	Inicio
		x = 0;
		/* inicio da tratativa dos campos */
	Fim;
Fim;
Senao 
Inicio
	aMsgErro = "Erro ao gerar Acess Token";

	Cancel(1);
Fim;

Funcao HTTP_POST();
Inicio
	HTTP_CREATE();

	/*  HttpAlteraCabecalhoRequisicao(vHTTP, "Username", "902a0f2c1f004861a8534be9fc1c06ec");

  HttpAlteraCabecalhoRequisicao(vHTTP, "Password", "e272f45EcD114872b3A873812188d5bd");      */

	HttpHabilitaSNI(vHTTP);

	@HttpAlteraConfiguracaoSSL(vHTTP,2);@

	HttpGet(vHTTP, aApi, aRetorno);

	@HttpGet(vHTTP, aApi, aPostData, aRetorno);@

	HttpLeCodigoResposta(vHTTP, vCodigo);
Fim;

Funcao HTTP_CREATE();
Inicio
	HttpObjeto(vHTTP);

	HttpDesabilitaErroResposta(vHTTP);

	HttpAlteraCabecalhoRequisicao(vHTTP, "Content-Type", "application/gzip");

	HttpAlteraCabecalhoRequisicao(vHTTP, "Accept", "application/gzip");

	Se(nUsaUTF8 = 1)
	{
		HttpAlteraCodifCaracPadrao(vHTTP, "utf-8");
	}
	Se(aAccessToken <> "")
	Inicio
		aAccessToken = "Basic " + aAccessToken;

		HttpAlteraCabecalhoRequisicao(vHTTP, "Authorization", aAccessToken);
	Fim;
Fim;