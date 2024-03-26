package custom.senior.apuracao;

import java.util.List;

import org.joda.time.LocalDate;
import com.senior.rh.ponto.apuracao.calculo.TipoHoraExtra;
import com.senior.rh.ponto.marcacoes.Marcacao;

import com.senior.ContextoGeralRH;
import com.senior.rh.ponto.apuracao.calculo.IntervaloCalculo;
import com.senior.rh.ponto.apuracao.calculo.TipoIntervalo;
import com.senior.rh.ponto.marcacoes.MarcacaoRegra;
import com.senior.rule.Rule;

@Rule(description = "Regra de Apuração Baklizi")
public class RegraApuracao extends Apuracao {

	@Override
	public void execute() {
		ajustarSituacoes();
	}

	private void ajustarSituacoes() {
		ContextoApuracao ctxApuracao = getContainer().getContextoApuracao();
		ContextoGeralRH ctxGeralRH = getContainer().getContextoGeral();
	
		// Buscando dados do Colaborador Processado
		LocalDate datPro = ctxApuracao.getData();
		int codHor = ctxApuracao.getHorario().getCodigo();
		int codSin = ctxApuracao.getHistoricoSindicato().getCodSin();
		int diaSem = ctxGeralRH.getDiaSem(datPro);
		int numEmp = ctxApuracao.getColaborador().getNumEmp();
		int tipCol = ctxApuracao.getColaborador().getTipCol();
		int numCad = ctxApuracao.getColaborador().getNumCad();
		
		// Calcula idade do colaborador
		LocalDate dataNascimento = ctxGeralRH.getColaborador(numEmp, tipCol, numCad).getDatNas();
		
		int diaHoje = datPro.getDayOfMonth();
		int mesHoje = datPro.getMonthOfYear();
		int anoHoje = datPro.getYear();
		
		int diaNascimento = dataNascimento.getDayOfMonth();
		int mesNascimento = dataNascimento.getMonthOfYear();
		int anoNascimento = dataNascimento.getYear();
		
		int idadeColaborador = anoHoje - anoNascimento;
		if (diaNascimento >= diaHoje && mesNascimento >= mesHoje) {
			idadeColaborador --;
		}
		
			
        // Gera situação de Adicional Noturno
		int adicionalNoturno = ctxApuracao.getHorSit(51, 302, 304);
		if(adicionalNoturno > 0){
			adicionalNoturno = (int) Math.round(((adicionalNoturno * 8) / 7));//converte as horas noturnas aplicando a hora noturna reduzida (52 minutos e meio)
			ctxApuracao.setHorSit(30, adicionalNoturno);
		}
			
				
		// Quem está no horário com carga horária de 6:20 (quem está em amamentação)
		// Se tiver falta e estiver neste horário tem que descontar as horas DSR (7:20) 
		// e não as horas previstas para trabalho
		int horasDsr = (int)ctxApuracao.getEscala().getHorasDsr();
 		int prvTrabalhoDiurno = ctxApuracao.getTotalMinutosPrevisto(codHor).getHorasDiurnas();
 		int prvTrabalhoNoturno = ctxApuracao.getTotalMinutosPrevisto(codHor).getHorasNoturnas();
 		int prvTrabalhoTotal = prvTrabalhoDiurno + prvTrabalhoNoturno;
		int totalFaltas = ctxApuracao.getHorSit(15,65);
		int qtdMarcacoes = ctxApuracao.getQtdMarcacoesRealizadas(true);

		if (prvTrabalhoTotal == totalFaltas) { // Faltou o dia todo!
			if ((qtdMarcacoes == 0) && (prvTrabalhoDiurno == 380)) {
				if (horasDsr > 0)
					ctxApuracao.setHorSit(34, horasDsr);
			}
			else {
				if (totalFaltas > 0)
					ctxApuracao.setHorSit(34, totalFaltas);				
			}
			ctxApuracao.zeraHorasSituacao(15,65);		
		}

		
		// Soma as Horas Extras para Crédito de Banco de Horas
		// Se for o sindicado "3 - Sindicado de Quarai", as horas extras realizadas no domingo sempre será paga 
		// e nunca irá para  banco de horas.
		int iTotalExtras = ctxApuracao.getHorSit(16, 66, 301, 302, 303, 304, 911);
		//if (ctxApuracao.getHorSit(iTotalExtras) > 0)
		if (iTotalExtras > 0)
			ctxApuracao.setHorSit(911, iTotalExtras);
		
		ctxApuracao.zeraHorasSituacao(16, 66, 301, 302, 303, 304);
		

		// Soma as Ausencias para Compensação do Banco de Horas
		if (ctxApuracao.getHorSit(15, 65, 103, 104, 101, 102, 105, 106, 912) > 0)
			ctxApuracao.setHorSit(912, ctxApuracao.getHorSit(15, 65, 103, 104, 101, 102, 105, 106, 912));
		
		ctxApuracao.zeraHorasSituacao(15, 65, 103, 104, 101, 102, 105, 106);

		// Acusa o dia de Folga e caso trabalhe em um dia de folga apura a situação de trabalho imprevisto
		int horasFolga = 0;
		if (codHor == 9996) {
			if (prvTrabalhoTotal > 0)
				horasFolga = prvTrabalhoTotal - ctxApuracao.getHorSit(911);
			else
				horasFolga = horasDsr - ctxApuracao.getHorSit(911);

			if (horasFolga > 0)
				ctxApuracao.setHorSit(900, horasFolga);

			if (qtdMarcacoes > 0)
				if (ctxApuracao.getHorSit(911) > 0)
					ctxApuracao.setHorSit(501, ctxApuracao.getHorSit(911));
		}
		
		     
		// Se a quantidade de marcações for impar, zerar todas as situações apuradas e gerar na situação 
		// "999-Marcações Inválidas" a previsão de trabalho para o dia
		if (qtdMarcacoes > 0) {		
			if (qtdMarcacoes % 2 > 0) {
				if (prvTrabalhoTotal > 0) {
					ctxApuracao.setHorSit(999, prvTrabalhoTotal);
				}
				else {
					if (horasDsr > 0)
						ctxApuracao.setHorSit(999, horasDsr);
					else
						ctxApuracao.setHorSit(999, 60);					
				}				
				ctxApuracao.zeraHorasSituacaoFaixa(1, 998);
			}
		}

		
		// Acusa Horas positivas maiores que 2 horas no dia		
		if (ctxApuracao.getHorSit(911) > 120) {
			ctxApuracao.setHorSit(500, ctxApuracao.getHorSit(911));
		}

		
		// Se tiver mais que 2:00 horas negativas, gera situação 499
		if ((ctxApuracao.getHorSit(912) >= 120) && 
				(ctxApuracao.getHorSit(912) != 240) &&
				(ctxApuracao.getHorSit(912) != 380) &&
				(ctxApuracao.getHorSit(912) != 440) && 
				(ctxApuracao.getHorSit(912) != 480)) {
			ctxApuracao.setHorSit(499, ctxApuracao.getHorSit(912));
		}

		
		// SITUAÇÕES QUE SERÃO USADAS PARA OS INCIDENTES
		// 994 - Entrada Antes das 07:00
		// 993 - Mais que 6:00 de trabalho sem intervalo
		// 996 - Saida Menor apos 22h
		// 990 - Intervalo Maior 3:00
		// 995 - Intervalo menor 15 min
		// 989 - Intervalo 15 minutos mulheres
		
		ctxApuracao.zeraHorasSituacao(989, 990,	993, 994, 995, 996);
		
		List<MarcacaoRegra> marcacoesRealizadas = ctxApuracao.getMarcacoesRealizadas(true);
		
		int contaMarcacoes = 0;
		int primeiraMarcacao = 0;
		int segundaMarcacao = 0;
		int totalHoras = 0;
		int horasIntervalo = 0;
		int diferencaMarcacao = 0;
		
		if (qtdMarcacoes != 0) {			
			for (MarcacaoRegra batidas:marcacoesRealizadas) {
				contaMarcacoes++;
				
				int horaMarcacao = batidas.getHora();
				
		        if ((contaMarcacoes == 1) && (horaMarcacao < 420)) // Entrada antes das 7:00
		        	if ((420 - horaMarcacao) > 0)
		        		ctxApuracao.setHorSit(994, 420 - horaMarcacao);
		        
		       if (contaMarcacoes % 2 == 0) { // Se marcacao par
		        	segundaMarcacao = horaMarcacao;
		        	totalHoras = totalHoras + (segundaMarcacao - primeiraMarcacao);
		        	if ((totalHoras >= 310) && (horasIntervalo == 0) && (diaSem == 0)) // Verifica se colaborador tem mais de 5:10 horas sem intervalo no domingo@
		        		ctxApuracao.setHorSit(993, 60);
		      
		        	if ((segundaMarcacao > 1320) && (idadeColaborador < 18))  // Verifica se o colaborador é menor de idade  com saida após as 22:00
		        		ctxApuracao.setHorSit(996, segundaMarcacao - 1320);

		        	diferencaMarcacao = segundaMarcacao - primeiraMarcacao;
		        	
		        	if (diferencaMarcacao > 360) //Verifica se trabalhou mais que 6:00
		        		ctxApuracao.setHorSit(993, diferencaMarcacao);
		        }
		        else { // Se marcacao impar
	        		primeiraMarcacao = horaMarcacao;
	        		if (contaMarcacoes > 1) {
	        			horasIntervalo = primeiraMarcacao - segundaMarcacao;
		        			
	        			if (horasIntervalo > 180) // Intervalor maior que 3:00
	        				ctxApuracao.setHorSit(990, horasIntervalo);

	        		}
	        	}
			}
		}
		
		
		
		
		//Verifica se colaboradora mulher fez intervalo caso tenha feito horas extras no dia
		//Intervalo de descanso de 15 minutos para mulheres
		//Conforme artigo 384 da CLT é obrigatório um descanso  de 15 minutos no mínimo, antes do início do período extraordinário.
				
		int refeicaoPrevista  = ctxApuracao.getMinutosRefeicaoPrevisto();//busca a quantidade de horas de intervalo de refeição previsto no horário
		// Intervalo 15 minutos mulheres
		int totalTrabalho = 0;
		int totalTrabalhoTolerancia = 0;
		int icontaIntervalos = 0;
		int iultimaMarcacao = 0;
		int itotalIntervalo = 0;
		
		boolean bAlertaDescanso = false;
		char tipoSexo = ctxApuracao.getColaborador().getSexo();
		
		if ((qtdMarcacoes != 0) && (iTotalExtras > 0) && (tipoSexo == 'F')) {
			contaMarcacoes = 0;
			for (MarcacaoRegra batidas:marcacoesRealizadas) {
				contaMarcacoes++;
				
				if (contaMarcacoes == 1) {
					primeiraMarcacao = batidas.getHora();
				}
				else
				if (contaMarcacoes == 2) {
					icontaIntervalos++;
					if (icontaIntervalos <= 2) {
						contaMarcacoes = 0;
						segundaMarcacao = batidas.getHora();
						iultimaMarcacao = batidas.getHora();
						
						totalTrabalho = totalTrabalho + (segundaMarcacao - primeiraMarcacao);
						
						totalTrabalhoTolerancia = totalTrabalho - prvTrabalhoTotal;
						if (totalTrabalhoTolerancia < 0)
							totalTrabalhoTolerancia = totalTrabalhoTolerancia * (-1);
						
						if (totalTrabalho > (prvTrabalhoTotal + 5)) {
							bAlertaDescanso = true;
							break;
						}
						
						if ((refeicaoPrevista == 0) && (totalTrabalhoTolerancia < 15)) {
							bAlertaDescanso = false;
							break;							
						}
							
					}
					else {
						contaMarcacoes = 0;
						segundaMarcacao = batidas.getHora();
						itotalIntervalo = (primeiraMarcacao - iultimaMarcacao);

						totalTrabalho = totalTrabalho + (segundaMarcacao - primeiraMarcacao);
						
						if ((totalTrabalho > (prvTrabalhoTotal + 5)) && (itotalIntervalo < 15)) {
							bAlertaDescanso = true;
							break;							
						}
											
						iultimaMarcacao = batidas.getHora();
					}
				}
			}
		}
		
		if (bAlertaDescanso) {
			ctxApuracao.setHorSit(989, totalTrabalho);
		}

		

		
		
		
		
		
			

		// Refeição menor que 1:00 hora
		int refeicaoRealizada = ctxApuracao.getHorasSeparadas(TipoIntervalo.REFEICAO).getTotalHoras();
		if ((refeicaoPrevista > 0) && (refeicaoRealizada < 60) && (ctxApuracao.getHorSit(001) > 360)) {
			ctxApuracao.setHorSit(991, refeicaoRealizada);
		}
	
		//Intervalor menor que 15 minutos
		if ((refeicaoPrevista > 0) && (refeicaoRealizada < 15) && (ctxApuracao.getHorSit(001) > 240)) {
			ctxApuracao.setHorSit(995, refeicaoRealizada);
		}

		// Interjornada menor que 11:00 horas
		if ((ctxApuracao.getHorasInterjornadaRealizada() > 0) && (ctxApuracao.getHorasInterjornadaRealizada() < 660)) {
			ctxApuracao.setHorSit(992, ctxApuracao.getHorasInterjornadaRealizada());
		}
		
		// Mais de 6:00 horas de trabalho sem intervalo
		List<IntervaloCalculo> intervalosCalculados = ctxApuracao.getIntervalosCalculados();
		for (IntervaloCalculo intervaloCalculo : intervalosCalculados) {
			if(intervaloCalculo.getTipo().equals(TipoIntervalo.TRABALHO)){//considera somente o intercalos trabalhados
				
				int iQtdHorasItervalo = intervaloCalculo.getIntervaloMinutos();
				
				//verifica se existe um intervalo de trabalho maior que 6:00
				if(iQtdHorasItervalo > 360){
					ctxApuracao.setHorSit(993, iQtdHorasItervalo);
					break;//se já encontrou um intervalo, não precisa verificar o restante dos intervalos
				}
			}
		}		
		
		// Se for domingo e tiver mais de 5:10
		if (diaSem == 7) {
			if (ctxApuracao.getHorasSeparadas(TipoIntervalo.EXTRA).getTotalHoras() > 310) {
				if (ctxApuracao.getIntervalosCalculados().size() == 1) {
					ctxApuracao.setHorSit(993, 60);
				}
			}
		}
		
		
		// Sindicato 003 - Quarai, Extra não vai para banco.
		if ((codSin == 3) && (diaSem == 7)) {
		    ctxApuracao.setHorSit(303, (ctxApuracao.getHorSit(001) + ctxApuracao.getHorSit(911)));
		    ctxApuracao.zeraHorasSituacao(001, 499, 911, 912, 913, 914, 915, 993);
			
		}

		// 6x1
		LocalDate dDatVer = datPro;
		int qtdDiaTra = 0;
		int hor6x1 = 0;
		
		if ((qtdMarcacoes >= 1) || (codHor < 9996)) {
			//busca a data de admissão do colaborador
			LocalDate datAdm = ctxGeralRH.getColaborador(numEmp, tipCol, numCad).getDatAdm();
			
			qtdDiaTra++;
			while (qtdDiaTra <= 20) {
				dDatVer = dDatVer.minusDays(1);
				
				if (dDatVer.compareTo(datAdm) <= 0)
					break;

		        hor6x1 = ctxApuracao.getHorarioPrevisto(dDatVer);
				
				boolean temMar6x1 = false;
				
				if(ctxApuracao.getHorSit(dDatVer, 1,51,301,302,303,304,307,308,501,911,912) > 0){
					temMar6x1 = true;
				}
				
				if (((hor6x1 == 9996) || ((hor6x1 == 9999)))  && (!temMar6x1)) {
					break;
				}
				
				qtdDiaTra++;
			}
		}
		
		if (qtdDiaTra >= 7) {
			ctxApuracao.setHorSit(910, horasDsr);
		}
	}	
}