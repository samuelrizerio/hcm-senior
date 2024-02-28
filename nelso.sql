SELECT fun.numemp EMPRESA_ID, fun.tipcol, fun.numcad, fun.nomfun, 
             case when afa.TIPSIT in (3,4,5,6,8,10,19,20,22) then 'AFASTADO' else 'ATIVO' end tipo,
	   AFA.SITAFA CODSIT_DATA_BASE, AFA.DESSIT DESSIT_DATA_BASE,
             count(*) QTD_ATIVOS
FROM R034FUN FUN 
LEFT JOIN R038HFI HFI 
ON HFI.NUMEMP = FUN.NUMEMP AND HFI.TIPCOL = FUN.TIPCOL AND HFI.NUMCAD = FUN.NUMCAD
AND HFI.DATALT = (SELECT MAX(HFI_INT.datalt) 
                                            FROM R038HFI HFI_INT 
                                         WHERE HFI_INT.NUMEMP = HFI.NUMEMP 
                                             AND HFI_INT.TIPCOL = HFI.TIPCOL
                                             AND HFI_INT.NUMCAD = HFI.NUMCAD
                                             AND HFI_INT.NUMEMP = HFI_INT.EMPATU
                                             AND HFI_INT.NUMCAD = HFI_INT.CADATU
                                             AND HFI_INT.DATALT < '2023-12-01'
                                        )
LEFT JOIN (select -- afastamento em andamento na data base
                     NUMEMP, TIPCOL, NUMCAD, DATAFA, HORAFA, DATTER, HORTER, SITAFA, SIT_AFA.DESSIT, SIT_AFA.TIPSIT
                     from R038AFA AFA -- Added table alias AFA
                     INNER JOIN R010SIT SIT_AFA ON SIT_AFA.CODSIT = AFA.SITAFA
                                    WHERE
					AFA.DATAFA = (SELECT MAX(ultafa.DATAFA)
                                                                             FROM R038AFA ultafa 
                                                                            WHERE ultafa.numemp = AFA.numemp
                                                                                AND ultafa.tipcol = AFA.tipcol
                                                                                AND ultafa.numcad = AFA.numcad
                                                                                AND ultafa.datafa < '2023-12-01') AND
										AFA.HORAFA = (SELECT MAX(ultafa.HORAFA) 
                                                                             FROM R038AFA ultafa 
                                                                            WHERE ultafa.numemp = AFA.numemp
                                                                                AND ultafa.tipcol = AFA.tipcol
                                                                                AND ultafa.numcad = AFA.numcad
                                                                                AND ultafa.datafa = AFA.datafa)) AFA   
ON AFA.NUMEMP = FUN.NUMEMP AND AFA.TIPCOL = FUN.TIPCOL AND AFA.NUMCAD = FUN.NUMCAD
INNER JOIN R010SIT SIT ON SIT.CODSIT = FUN.SITAFA
LEFT JOIN (select numemp, tipcol, numcad, sum(qtdsld) qtdsld
                        from R040PER where sitper = 0
			group by numemp, tipcol, numcad) PER ON FUN.NUMEMP = PER.NUMEMP AND FUN.TIPCOL = PER.TIPCOL AND FUN.NUMCAD = PER.NUMCAD 
WHERE FUN.TIPCOL IN (1) 
    AND FUN.NUMEMP = 1
    AND (AFA.SITAFA IS NULL OR AFA.TIPSIT NOT IN (7)) -- DEMITIDOS
    AND FUN.numcad in (6,66)
GROUP BY fun.numemp, fun.tipcol, fun.numcad, fun.nomfun,
                    SIT.CODSIT, SIT.DESSIT,
		  afa.TIPSIT, AFA.SITAFA, AFA.DESSIT