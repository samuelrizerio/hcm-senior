/*Regra Tabela Aprovacoes*/
Definir Alfa xMensagem1;
Definir Alfa xMensagem2;
Definir Alfa xMensagem3;
Definir Alfa xMensagem4;
Definir Data dDatReg;
Definir Data dDatHoj;
Definir Alfa aSimNao;
Definir Alfa aUSU_UniTra;
Definir Alfa aUSU_ProNom;
Definir Alfa aUSU_AfeSex;
Definir Alfa aUSU_IdeGer;
Definir Alfa aUSU_NesAda;
Definir Alfa aUSU_DesAda;
Definir Alfa aUSU_PaiMae;
Definir Alfa aUSU_IntAle;
Definir Alfa aUSU_DesTra;
Definir Alfa aUSU_DieAli;
Definir Alfa aUSU_AleMed;
Definir Alfa aUSU_DesMed;
Definir Alfa aUSU_PosAni;
Definir Alfa aUSU_AniEst;
Definir Alfa aUSU_AtiFis;
Definir Alfa aUSU_AtiFis;
Definir Alfa aUSU_AtiMen;
Definir Alfa aUSU_ModCam;
Definir Alfa aUSU_DoaSan;
Definir Alfa aUSU_DoaMed;
Definir Alfa aUSU_ConEme;
Definir Alfa aUSU_TelEme;
Definir Alfa aUSU_CotDef;
Definir Alfa aUSU_PosTra;
Definir Alfa aNomSoc;
Definir Alfa aApeFun;
Definir Alfa aDefFis;
Definir Alfa aEmaCom;
Definir Alfa aTxtEma;
Definir Alfa aAssEma;
Definir Cursor Cur_Email;
Definir Funcao RegistrarAprovador();
Definir Funcao LimparRegistro();
Definir Funcao RegistrarR034FUN();
Definir Funcao RegistrarR034CPL();

nCodUsu = codusu;
dDatHoj = datsis;

Se(CodOpe = "DepoisAlterar")
{
	@Coleta registros@
	nNumEmp = Aprovacoes_CodEmpresa;
	nTipCol = Aprovacoes_TipoColab;
	nNumCad = Aprovacoes_CodMatricula;
	dDatReg = Aprovacoes_DataRegistro;
	aSimNao = Aprovacoes_AprSimNao;
	nUSU_GraIns = Aprovacoes_GrauInstrucao;
	nUSU_CodAcn = Aprovacoes_CursoFormacao;
	aUSU_UniTra = Aprovacoes_UnidadeTrabalho;
	aUSU_ProNom = Aprovacoes_PronomeAdequado;
	aUSU_AfeSex = Aprovacoes_OrientacaoAfetivo;
	aUSU_IdeGer = Aprovacoes_IdentidadeGenero;
	aUSU_NesAda = Aprovacoes_NecessidadeAdapt;
	nUSU_QtdFil = Aprovacoes_QuantidadeFilho;
	nUSU_QtdPes = Aprovacoes_QtdPessoas;
	aUSU_DesAda = Aprovacoes_DescrNecessidade;
	nUSU_QtdEnt = Aprovacoes_QtdFilhos;
	aUSU_PaiMae = Aprovacoes_PaiMaeSolo;
	aUSU_IntAle = Aprovacoes_IntoleranciaAlim;
	aUSU_DesTra = Aprovacoes_DeslocaTrabalho;
	aUSU_DieAli = Aprovacoes_DietaAlimentar;
	aUSU_AleMed = Aprovacoes_AlergiaMed;
	aUSU_DesMed = Aprovacoes_DescrMedicamento;
	aUSU_PosAni = Aprovacoes_PossuiAnimal;
	aUSU_AniEst = Aprovacoes_AnimalEstimacao;
	aUSU_AtiFis = Aprovacoes_AtivFisica;
	nUSU_TamCal = Aprovacoes_TamanhoCalcado;
	aUSU_AtiMen = Aprovacoes_AtividadeMental;
	nUSU_TamCam = Aprovacoes_TamanhoCamiseta;
	aUSU_ModCam = Aprovacoes_ModeloCamiseta;
	aUSU_DoaSan = Aprovacoes_DoaSangue;
	aUSU_DoaMed = Aprovacoes_DoaMedula;
	aUSU_ConEme = Aprovacoes_ContatoEmerg;
	aUSU_TelEme = Aprovacoes_TelefoneEmerg;
	aUSU_CotDef = Aprovacoes_CotaDeficiente;
	aUSU_PosTra = Aprovacoes_PosicaoTrab;
	aNomSoc = Aprovacoes_NomeSocial;
	aApeFun = Aprovacoes_ApelidoFun;
	nRacCor = Aprovacoes_RacaCor;
	nCodRlr = Aprovacoes_CodReligiao;
	aDefFis = Aprovacoes_DefFisico;
	nCodDef = Aprovacoes_CodDeficiencia;

	Se(aSimNao = 'S')
	{
		RegistrarAprovador();
		RegistrarR034FUN();
		RegistrarR034CPL();
	}
	Senao Se(aSimNao = 'N')
	{
		RegistrarAprovador();
		/*Chama função de enviar e-mail html ou ativa notificacao G7 para colaborador*/
		Cur_Email.SQL "SELECT                                                                       \
                           EmaCom                                                                   \
                       FROM                                                                         \
                           R034CPL                                                                  \
                       WHERE                                                                        \
                           NumEmp = :nNumEmp                                                        \
                           AND TipCol = :nTipCol                                                    \
                           AND NumCad = :nNumCad";
		Cur_Email.AbrirCursor();
		Se(Cur_Email.Achou)
		{
			aEmaCom = Cur_Email.EmaCom;
		}
		Cur_Email.FecharCursor();
		aAssEma = "Censo ESG Reprovado";
		aTxtEma = "Olá! Seu registro no Censo ESG foi reprovado pelo RH. Gentileza acesse a página do Censo no Portal e ajuste o cadastro.";
		EnviaEmailHTML(RmtEma, "samuel.chaves@consultorseniorsistemas.com.br", CcpEma, CcoEma, aAssEma, aTxtEma, AnxEma, 0, 0); @trocar por aEmaCom@
	}
	Senao 
	Inicio
		Mensagem(Retorna, "Necessário Aprovar com Sim ou Não");
		LimparRegistro();
	Fim;
}
x = 0;

Funcao RegistrarAprovador();
{
	IniciarTransacao();
	ExecSqlEx("UPDATE                                                                               \
                   USU_TValESG                                                                      \
               SET                                                                                  \
                   USU_CodUsu = :nCodUsu,                                                           \
                   USU_DatApr = :dDatHoj                                                            \
               WHERE                                                                                \
                   USU_NumEmp = :nNumEmp                                                            \
                   AND USU_TipCol = :nTipCol                                                        \
                   AND USU_NumCad = :nNumCad                                                        \
                   AND USU_DatReg = :dDatReg", xErro1, xMensagem1);
	Se(xErro1 = 0)
	{
		FinalizarTransacao();
	}
	Senao 
	Inicio
		DesfazerTransacao();
	Fim;
}

Funcao LimparRegistro();
{
	IniciarTransacao();
	ExecSqlEx("UPDATE                                                                               \
                   USU_TValESG                                                                      \
               SET                                                                                  \
                   USU_CodUsu = NULL,                                                               \
                   USU_DatApr = NULL,                                                               \
                   USU_SimNao = NULL                                                                \
               WHERE                                                                                \
                   USU_NumEmp = :nNumEmp                                                            \
                   AND USU_TipCol = :nTipCol                                                        \
                   AND USU_NumCad = :nNumCad                                                        \
                   AND USU_DatReg = :dDatReg", xErro2, xMensagem2);
	Se(xErro2 = 0)
	{
		FinalizarTransacao();
	}
	Senao 
	Inicio
		DesfazerTransacao();
	Fim;
}

Funcao RegistrarR034FUN();
{
	IniciarTransacao();
	ExecSqlEx("UPDATE                                                                               \
                   R034FUN                                                                          \
               SET                                                                                  \
                   GraIns = :nUSU_GraIns,                                                           \
                   ApeFun = :aApeFun,                                                               \
                   RacCor = :nRacCor,                                                               \
                   DefFis = :aDefFis,                                                               \
                   USU_UniTra = :aUSU_UniTra,                                                       \
                   USU_ProNom = :aUSU_ProNom,                                                       \
                   USU_AfeSex = :aUSU_AfeSex,                                                       \
                   USU_IdeGer = :aUSU_IdeGer,                                                       \
                   USU_NesAda = :aUSU_NesAda,                                                       \
                   USU_QtdFil = :nUSU_QtdFil,                                                       \
                   USU_QtdPes = :nUSU_QtdPes,                                                       \
                   USU_DesAda = :aUSU_DesAda,                                                       \
                   USU_QtdEnt = :nUSU_QtdEnt,                                                       \
                   USU_PaiMae = :aUSU_PaiMae,                                                       \
                   USU_IntAle = :aUSU_IntAle,                                                       \
                   USU_DesTra = :aUSU_DesTra,                                                       \
                   USU_DieAli = :aUSU_DieAli,                                                       \
                   USU_AleMed = :aUSU_AleMed,                                                       \
                   USU_DesMed = :aUSU_DesMed,                                                       \
                   USU_PosAni = :aUSU_PosAni,                                                       \
                   USU_AniEst = :aUSU_AniEst,                                                       \
                   USU_AtiFis = :aUSU_AtiFis,                                                       \
                   USU_TamCal = :nUSU_TamCal,                                                       \
                   USU_AtiMen = :aUSU_AtiMen,                                                       \
                   USU_TamCam = :nUSU_TamCam,                                                       \
                   USU_ModCam = :aUSU_ModCam,                                                       \
                   USU_DoaSan = :aUSU_DoaSan,                                                       \
                   USU_DoaMed = :aUSU_DoaMed,                                                       \
                   USU_CodAcn = :nUSU_CodAcn,                                                       \
                   USU_ConEme = :aUSU_ConEme,                                                       \
                   USU_TelEme = :aUSU_TelEme,                                                       \
                   USU_CotDef = :aUSU_CotDef,                                                       \
                   CotDef = :aUSU_CotDef,                                                           \
                   CodDef = :nCodDef,                                                               \
                   USU_PosTra = :aUSU_PosTra                                                        \
               WHERE                                                                                \
                   NumEmp = :nNumEmp                                                                \
                   AND TipCol = :nTipCol                                                            \
                   AND NumCad = :nNumCad", xErro3, xMensagem3);
	Se(xErro3 = 0)
	{
		FinalizarTransacao();
	}
	Senao 
	Inicio
		DesfazerTransacao();
	Fim;
}
Funcao RegistrarR034CPL();
{
	IniciarTransacao();
	ExecSqlEx("UPDATE                                                                               \
                   R034CPL                                                                          \
               SET                                                                                  \
                   USU_CodAcn = :nUSU_CodAcn,                                                       \
                   USU_GraIns = :nUSU_GraIns,                                                       \
                   NomSoc = :aNomSoc,                                                               \
                   CodRlr = :nCodRlr                                                                \
               WHERE                                                                                \
                   NumEmp = :nNumEmp                                                                \
                   AND TipCol = :nTipCol                                                            \
                   AND NumCad = :nNumCad", xErro4, xMensagem4);
	Se(xErro4 = 0)
	{
		FinalizarTransacao();
	}
	Senao 
	Inicio
		DesfazerTransacao();
	Fim;
}