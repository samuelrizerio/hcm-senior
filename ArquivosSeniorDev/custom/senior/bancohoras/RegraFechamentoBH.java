package custom.senior.bancohoras;

import java.util.List;

import org.joda.time.LocalDate;

import com.senior.ContextoGeralRH;
import com.senior.dataset.ICursor;
import com.senior.dataset.MappedParamProvider;
import com.senior.rh.entities.readonly.IR066SIT;
import com.senior.rh.ponto.colaborador.HistoricoAfastamento;
import com.senior.rule.Rule;

import TabelasCustomizadas.R034FUN_Custom;
import custom.senior.RegraBancoHorasException;

@Rule(description = "Regra Fechamento BH")
public class RegraFechamentoBH extends FechamentoBH {
    @Override
    public void execute() {
        ContextoFechamentoBH contextoFechamentoBH = getContainer().getContextoFechamentoBH();
        ContextoGeralRH contextoGeral = getContainer().getContextoGeral();

        int numEmp = contextoFechamentoBH.getColaborador().getNumeroEmpresa();
        int tipCol = contextoFechamentoBH.getColaborador().getTipoColaborador();
        int numCad = contextoFechamentoBH.getColaborador().getNumeroCadastro();
        int bancoHoras = contextoFechamentoBH.getBancoHoras();

        LocalDate dataInicial = contextoFechamentoBH.getDataInicial();
        LocalDate dataFinal = contextoFechamentoBH.getDataFinal();
                
        int iPgtExtras = 0;
        int saldoAtual = 0;
        int iDiasFalta = 0;
        
        boolean bTemAfastamento = false;

        MappedParamProvider paramProvider = new MappedParamProvider();
        paramProvider.setParam("NumEmp", numEmp);
        paramProvider.setParam("TipCol", tipCol);
        paramProvider.setParam("NumCad", numCad);

        try{
        ICursor<R034FUN_Custom> Cur_R034FUN = getContainer().getEntitySession().newCursor(R034FUN_Custom.class);
        Cur_R034FUN.addFilter("NumEmp = :NumEmp and TipCol = :TipCol and NumCad = :NumCad", paramProvider);			        
        Cur_R034FUN.open();//Abre o cursor já filtrado
        try {
        	R034FUN_Custom colab = Cur_R034FUN.newBuffer();//cria um objeto com os dados retornados do cursor
           
        	if (Cur_R034FUN.next()) {//Se localizou as situações
        		Cur_R034FUN.read(colab);
            	
            	if(!colab.isUSU_PAGEXTNull())
            		iPgtExtras = colab.getUSU_PAGEXT();//se tiver alguma quantidade de horas deve pagar
			}
		} finally {
			Cur_R034FUN.close(); // fecha o cursor
        }
        }catch(Exception e){
        	throw new RegraBancoHorasException(e.getMessage());
        }

        if(iPgtExtras > 0) {//se possui horas cadastradas para pagamento efetua o pagamento até o limite
        	List<HistoricoAfastamento> historicosAfastamento = contextoGeral.getHistoricosAfastamento(numEmp, tipCol, numCad, dataFinal);//busca o afastamento no último dia do mês
        	if(historicosAfastamento != null){//achou histórico de afastamentos
        		//busca pelo afastamentos
        		for (int i = 0; i < historicosAfastamento.size(); i++) {
        			int iSitAfa = historicosAfastamento.get(i).getSitAfa();
        			
        			if((iSitAfa >= 2) && (iSitAfa <= 6)){
        				bTemAfastamento = true;
        				break;//se tiver mais de uma afastamento, e já achou um deles, não precisa percorrer o resto da lista
        			}
				}        		
        	}
        	
        	//se não tiver afastamento busca a situação de faltas durante o perído
        	if(!bTemAfastamento){
        		//verifica se existem mais de 15 dias de faltas
        		MappedParamProvider params_R066SIT = new MappedParamProvider(); 
				params_R066SIT.setParam("NumEmp", numEmp);
				params_R066SIT.setParam("TipCol", tipCol);
				params_R066SIT.setParam("NumCad", numCad);
				params_R066SIT.setParam("DatIni", dataInicial);
				params_R066SIT.setParam("DatFim", dataFinal);
				
				ICursor<IR066SIT> cur_R066SIT = getContainer().getEntitySession().newCursor(IR066SIT.class);
	        	cur_R066SIT.addFilter("NumEmp = :NumEmp AND TipCol = :TipCol AND NumCad = :NumCad " +
	        						"AND DatApu BETWEEN :DatIni AND :DatFim AND CodSit = 15", params_R066SIT);			        
		        cur_R066SIT.open();//Abre o cursor já filtrado
		        try {
		            while (cur_R066SIT.next()) {//Se localizou as situações
		            	iDiasFalta = iDiasFalta + 1;//conta a quantidade de dias de Falta no período
					}
				} finally {
					cur_R066SIT.close(); // fecha o cursor
		        }
		        
		        if(iDiasFalta < 15){//somente realiza a integração se tiver menos de 15 dias de faltas no mês
		        	saldoAtual = contextoGeral.getSaldoBancoHoras(bancoHoras, numEmp, tipCol, numCad, dataFinal.plusDays(1));
		        	/*
		        	 * - Retirado da regra pois o campo foi convertido no banco de dados para minutos (Gilvan Bez)
		        	iPgtExtras = iPgtExtras * 60;//converte a quantidade de horas em minutos
		        	*/
		        	if (saldoAtual > 0) {
		        		if(iPgtExtras > saldoAtual){
		        			contextoFechamentoBH.realizarFechamento(dataFinal, saldoAtual);//integra o total de horas positivas do banco
		        		}else{
		        			contextoFechamentoBH.realizarFechamento(dataFinal, iPgtExtras);//integra o limite de horas informado no cadastro de colaborador
		        		}
		        	}
		        }
        	}
        }
    }
}
