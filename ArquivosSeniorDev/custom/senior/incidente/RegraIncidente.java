package custom.senior.incidente;
/*
 * import java.util.List;
 * import com.senior.rh.ponto.apuracao.SituacaoApuradaIncidente;
 * import org.joda.time.LocalDate;
*/

import custom.br.com.senior.incidente.ContextoIncidente;
import custom.br.com.senior.incidente.PontoRegraIncidente;

public class RegraIncidente extends PontoRegraIncidente {
	@Override
	public void calcular(ContextoIncidente contextoIncidente) {
		/*
		// A regra foi desabilitada, pois a empresa hoje não está utilizando a rotina de incidentes do GPo
		 * Todas estes incidentes estão sendo apurados na regra de apuração... 
		 * e de acordo com as situações apuradas é gerado o incidente correspondente nesta regra.
		//Pega o dia apurado no contexto de incidentes
		LocalDate dataApuracao = contextoIncidente.getDataApuracao();

		
		// Gera incidentes pela situações apuradas
		List<SituacaoApuradaIncidente> situacoesApuradas = contextoIncidente.getSituacoesApuradas(dataApuracao);
		
		for (SituacaoApuradaIncidente apuradas:situacoesApuradas) {
			if (apuradas.getCodigoSituacao() == 500)
				contextoIncidente.criarIncidente(9);
			else			
			if (apuradas.getCodigoSituacao() == 501) 
				contextoIncidente.criarIncidente(60);				
			else		
			if (apuradas.getCodigoSituacao() == 910) 
				contextoIncidente.criarIncidente(12);				
			else			
			if (apuradas.getCodigoSituacao() == 989) 
				contextoIncidente.criarIncidente(13);				
			else			
			if (apuradas.getCodigoSituacao() == 990) 
				contextoIncidente.criarIncidente(64);
			else			
			if (apuradas.getCodigoSituacao() == 991) 
				contextoIncidente.criarIncidente(63);
			else			
			if (apuradas.getCodigoSituacao() == 992) 
				contextoIncidente.criarIncidente(3);
			else			
			if (apuradas.getCodigoSituacao() == 993) 
				contextoIncidente.criarIncidente(62);				
			else			
			if (apuradas.getCodigoSituacao() == 995) 
				contextoIncidente.criarIncidente(65);
			else			
			if (apuradas.getCodigoSituacao() == 996) 
				contextoIncidente.criarIncidente(61);
			else			
			if (apuradas.getCodigoSituacao() == 999) 
				contextoIncidente.criarIncidente(11);
		}
*/	
	}
}