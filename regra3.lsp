/*Regra Tabela Registros*/
Definir Alfa ConsultaSQL;
Definir Alfa aCursor;
Definir Alfa aCursor2;
Definir Alfa cNumEmp;
Definir Alfa cTipCol;
Definir Alfa cNumCad;
Definir Alfa xMensagem;
Definir Alfa edUSU_TxtAce;
Definir Alfa aDataExtenso;
Definir Alfa aHoraExtenso;
Definir Data edUSU_DatReg;
Definir Funcao MinhaMatricula();

Se(CodOpe = "Iniciando")
{
	@coleta empresa tipcol matricula do usuario@
	MinhaMatricula();

	nNumEmp = nnNumEmp;
	nTipCol = nnTipCol;
	nNumCad = nnNumCad;

	@consultar se tem na tabela usu_tvalESG@
	ConsultaSQL = "SELECT USU_NumEmp,USU_TipCol,USU_NumCad,USU_DatReg FROM USU_TVALESG                                         \
  WHERE USU_NumEmp = :nNumEmp AND USU_TipCol = :nTipCol AND USU_NumCad = :nNumCad ORDER BY USU_DatReg DESC";

	Definir Data dDatReg;
	dDatReg = DatSis;
	nHorReg = horsis;

	@consultar se tem na tabela usu_tvalESG@
	SQL_Criar(aCursor2);
	SQL_DefinirComando(aCursor2, ConsultaSQL);
	SQL_DefinirInteiro(aCursor2, "nNumEmp", nNumEmp);
	SQL_DefinirInteiro(aCursor2, "nTipCol", nTipCol);
	SQL_DefinirInteiro(aCursor2, "nNumCad", nNumCad);
	SQL_AbrirCursor(aCursor2);
	Se(SQL_EOF(aCursor2) = 0) @Possui registro, coleta@
	{
		SQL_RetornarInteiro(aCursor2, "USU_NumEmp", ccNumEmp);
		SQL_RetornarInteiro(aCursor2, "USU_TipCol", ccTipCol);
		SQL_RetornarInteiro(aCursor2, "USU_NumCad", ccNumCad);
		SQL_RetornarData(aCursor2, "USU_DatReg", ccDatReg);
	}
	SQL_FecharCursor(aCursor2);
	SQL_Destruir(aCursor2);
	@se tem na tabela: passa os parametros chaves e lista na tela@
	Se((ccNumEmp <> 0) e (nNumEmp = ccNumEmp) e (ccTipCol <> 0) e (nTipCol = ccTipCol) e (ccNumCad <> 0) e (nNumCad = ccNumCad) e (ccDatReg <> 0))
	{
		@passa os parametros chaves e lista na tela@
		edUSU_NumEmp = ccNumEmp;
		edUSU_TipCol = ccTipCol;
		edUSU_NumCad = ccNumCad;
		dDatReg = ccDatReg;
		edUSU_DatReg = ccDatReg;
		x = 0;
	}
	@se nao tem, insere tudo null com data de hoje;@
	Senao 
	Inicio
		edUSU_NumEmp = nNumEmp;
		edUSU_TipCol = nTipCol;
		edUSU_NumCad = nNumCad;
		edUSU_DatReg = dDatReg;
		edUSU_HorReg = nHorReg;

		@faz as conversoes de data para string de data e hora para string de hora@
		ConverteMascara(3, edUSU_DatReg, aDataExtenso, "DD/MM/YYYY");
		ConverteMascara(4, edUSU_HorReg, aHoraExtenso, "hh:mm");
		edUSU_TxtAce = "Aceito pelo colaborador em: " + aDataExtenso + " às " + aHoraExtenso;
		Se((edUSU_NumEmp <> 0) e (edUSU_TipCol <> 0) e (edUSU_NumCad <> 0) e (edUSU_DatReg <> 0))
		{
			IniciarTransacao();
			ExecSqlEx("INSERT INTO USU_TVALESG(                                                     \
                           USU_NumEmp,                                                              \
                           USU_TipCol,                                                              \
                           USU_NumCad,                                                              \
                           USU_DatReg,                                                              \
                           USU_HorReg,                                                              \
                           USU_TxtAce,                                                              \
                           USU_SimNao                                                               \
                       ) VALUES (                                                                   \
                           :edUSU_NumEmp,                                                           \
                           :edUSU_TipCol,                                                           \
                           :edUSU_NumCad,                                                           \
                           :edUSU_DatReg,                                                           \
                           :edUSU_HorReg,                                                           \
                           :edUSU_TxtAce,                                                           \
                           'N'                                                                      \
                       )", xErro, xMensagem);
			Se(xErro = 0)
			{
				FinalizarTransacao();
			}
			Senao 
			Inicio
				DesfazerTransacao();
			Fim;
		}
		x = 0;
	Fim;
}

Se(CodOpe = "DepoisAlterar")
{
	IniciarTransacao();
	ExecSqlEx("UPDATE                                                                               \
                   USU_TVALESG                                                                      \
               SET                                                                                  \
                   USU_SimNao = NULL                                                                \
               WHERE                                                                                \
                   USU_NumEmp = :nnNumEmp                                                           \
                   AND USU_TipCol = :nnTipCol                                                       \
                   AND USU_NumCad = :nnNumCad", xErro, xMensagem);
	Se(xErro = 0)
	{
		FinalizarTransacao();
	}
	Senao 
	Inicio
		DesfazerTransacao();
	Fim;
	x = 0;
}

@coletar matricula e empresa do usuario@
Funcao MinhaMatricula();
{
	nCodUsu = CodUsu;
	ConsultaSQL = "SELECT R034FUN.NumEmp,R034FUN.TipCol,R034FUN.NumCad FROM R034USU, R034FUN WHERE R034FUN.NumEmp = R034USU.NumEmp \
  AND R034FUN.TipCol = R034USU.TipCol AND R034FUN.NumCad = R034USU.NumCad AND R034USU.CodUsu = :nCodUsu";
	SQL_Criar(aCursor);
	SQL_DefinirComando(aCursor, ConsultaSQL);
	SQL_DefinirInteiro(aCursor, "nCodUsu", nCodUsu);
	SQL_AbrirCursor(aCursor);
	Se(SQL_EOF(aCursor) = 0)
	{
		SQL_RetornarInteiro(aCursor, "NumEmp", nnNumEmp);
		SQL_RetornarInteiro(aCursor, "TipCol", nnTipCol);
		SQL_RetornarInteiro(aCursor, "NumCad", nnNumCad);
	}
	SQL_FecharCursor(aCursor);
	SQL_Destruir(aCursor);
}