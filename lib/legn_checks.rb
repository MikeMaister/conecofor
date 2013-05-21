module Legn_checks

  #--- Compliance ---

  #CHECK N1: FORMATO DATI
  #controllo che i campi integer e decimal abbiano effettivamente valori interi o decimali immessi
  def data_format(record,row)
    #è una stringa
    stringa = /\D+/
    #se i dati che dovrebbero essere un numero,in realtà sono una stringa
    if record.cod_plot =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.subplot =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.copertura =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Copertura",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.altezza =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Altezza",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.eta_strutturale =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Età Strutturale",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.danni_meccanici =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Danni Meccanici",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.danni_parassitari =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Danni_parassitari",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.radicanti =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Radicanti Esterni",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N2: OBBLIGATORIETA' CAMPI
  def null_check(record,row)
    #se gli attributi obbligatori sono nulli
    if record.data.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Data",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.cod_plot.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.subplot.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #FACOLTATIVI
    if mandatory?(session[:mask_name],"Legnose","eta_strutturale")
      if record.eta_strutturale.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Età strutturale",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Legnose","danni_meccanici")
      if record.danni_meccanici.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Danni Meccanici",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Legnose","altezza")
      if record.altezza.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Altezza",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Legnose","danni_parassitari")
      if record.danni_parassitari.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Danni Parassitari",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Legnose","copertura")
      if record.copertura.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Legnose","radicanti_esterni")
      if record.radicanti.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Radicanti Esterni",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N3: RIFERIMENTO A TABELLE
  def external_reference_check(record,row)
    #riferimenti al plot
    plot = Plot.find(:first, :conditions => ["numero_plot = ? AND deleted = false", record.cod_plot])
    #se il plot non esiste
    if plot.blank?
      save_error(record,"Riferimento al Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #a meno che la specie non sia presente
    unless record.specie.blank?
      #riferimenti alla specie
      specie = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie])
      #se la specie non esiste
      if specie.blank?
        save_error(record,"Riferimento a Specie",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N4: UNICITA' RECORD
  def unique_record_check(record,row)
    #controllo che non sia presente di nuovo la copertura per quella specie in quel plot-subplot
    if !record.copertura.nil? && record.copertura != 0 && !record.specie.blank?
      #recupero tutte le info necessarie per memorizzare la chiave primaria
      plot_id = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false",record.cod_plot]).id
      specie_id = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]).id
      active_campaign_id = Campagne.find(:first,:conditions => ["active = true"]).id
      file = ImportFile.find(session[:file_id])
      #cerco la chiave primaria
      pk = Legnose.find(:first,:conditions => ["campagne_id = ? AND plot_id = ? AND subplot = ? AND file_name_id = ? AND import_num = ? AND specie_id = ?", active_campaign_id, plot_id, record.subplot, file.id, file.import_num,specie_id])
      #se già è presente
      unless pk.blank?
        #salvo l'errore
        save_error(record,"Copertura già presente per questa specie in questo plot, subplot",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N5: CORRISPONDENZA NOME FILE - PLOT
  def file_name_plot_to_plot(record,row)
    #rintraccio il file
    file = ImportFile.find(session[:file_id])
    #numero del plot
    plot_number = /\d+\D+(\d+)[.]\S*/
    #confronto
    file.file_name =~ plot_number
    #estrapolo il numero del plot
    file_plot = $1
    file_plot = file_plot.to_i
    #se il plot indicato nel nome del file non è uguale a quello contenuto all'interno
    unless file_plot == record.cod_plot
      #salvo l'errore
      save_error(record,"File name - Plot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N6: CORRISPONDENZA NOME FILE - Data
  def file_name_date_to_date(record,row)
    #rintraccio il file
    file = ImportFile.find(session[:file_id])
    #campagna 199X
    camp90 = /([9])(\d)\D+\d+[.]\S*/
    #campagna 20XX in avanti
    camp00 = /(\d+)\D+\d+[.]\S*/
    #se il file si riferisce alle campagne dal 1990 al 1999
    if file.file_name =~ camp90
      #anno = 19 + numeri rimanenti
      anno = "19" + $1 + $2
      #se il file si riferisce alle campagne dal 2000 al 2099
    elsif file.file_name =~ camp00
      #anno = 20 + numeri rimanenti
      anno = "20" + $1
    end
    #memorizzo temporaneamente la data per poterci lavorare sopra
    data_temp = Legnose.new
    data_temp.data = record.data
    #a meno che l'anno della data del record non corrisponda a quello del nome del file
    unless data_temp.data.year == anno.to_i
      #salvo l'errore
      save_error(record,"File name - Data",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N7: DOMINIO DEGLI ATTRIBUTI
  def attr_domain(record,row)
    #SUBPLOT
    #a meno che il numero di subplot sia incluso tra 1 e 12
    unless (1..100).include?(record.subplot)
      #salvo l'errore
      save_error(record,"Wrong subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #ETA_STRUTTURALE
    #a meno che il campo non sia vuoto
    unless record.eta_strutturale.blank?
      #a meno che esterno valga 1 o 2
      unless (1..2).include?(record.eta_strutturale)
        #salvo l'errore
        save_error(record,"Wrong eta_strutturale",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #DANNI_MECCANICI
    #a meno che il campo non sia vuoto
    unless record.danni_meccanici.nil?
      #a meno che priest valga 0 o 1
      unless (0..1).include?(record.danni_meccanici)
        #salvo l'errore
        save_error(record,"Wrong danni_meccanici",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #DANNI_PARASSITARI
    #a meno che il campo non sia vuoto
    unless record.danni_parassitari.nil?
      #a meno che priest valga 0 o 1
      unless (0..1).include?(record.danni_parassitari)
        #salvo l'errore
        save_error(record,"Wrong danni_parassitari",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #RADICANTI_ESTERNI
    #a meno che il campo non sia vuoto
    unless record.radicanti.blank?
      #a meno che esterno valga 1 o 2
      unless (1..2).include?(record.radicanti)
        #salvo l'errore
        save_error(record,"Wrong radicanti_esterni",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #--- Simple Range ---

  #SR CHECK N1: DATA RECORD in DATA CAMPAGNA
  def data_range(record)
    #carico la campagna attiva
    camp = Campagne.find(:first,:conditions => ["active = true"])
    #a meno che la data non rientri nel range della campagna
    unless record.data >= camp.inizio && record.data <= camp.fine
      #salvo l'errore simple range
      simple_range_error(record,"Data range")
    end
  end

  #SR CHECK N2
  def do_src_on_rows(row,camp_id)
    #Legnose N.1
    #solo se la copertura non è nulla
    unless row.copertura.nil?
      copertura = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'copertura' AND reference_table = 'legnose' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.copertura <= copertura[0].max && row.copertura >= copertura[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{copertura[0].attr}")
      end
    end
    #Legnose N.2
    #solo se altezza non è nullo
    unless row.altezza.nil?
      altezza = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'altezza' AND reference_table = 'legnose' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.altezza <= altezza[0].max && row.altezza >= altezza[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{altezza[0].attr}")
      end
    end
  end

  #--- Multiple Parameter ---

  #MP CHECK N1: presenza di tutti i subplot
  def all_subplot_100?
    #trovo la campagna aperta
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file
    file = ImportFile.find(session[:file_id])
    #memorizzo il numero dei subplot diversi tra loro interni
    num_su_in = Legnose.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM legnose WHERE campagne_id = #{open_camp.id} AND import_num = #{file.import_num} AND file_name_id = #{file.id}")

    #se i subplot non sono 100
    if num_su_in != 100
      #segnalo l'errore
      global_error("Mancano alcuni subplot",file)
    end
  end

  #MP CHECK N2: Quando radicanti = 1 gli altri campi not null
  def rad1_not_null(row)
    unless row.radicanti_esterni.nil?
      if row.radicanti_esterni == 1
        if row.altezza.nil? || row.eta_strutturale.nil? || row.danni_meccanici.nil? || row.danni_parassitari.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Radicanti Esterni = 1, violazioine not null in Altezza,età strutturale,danni meccanici,danni parassitari")
        end
      end
    end
  end

  #MP CHECK N3: Quando radicanti = 2 allora copertura e altezza not null, mentre gli altri campi null
  def rad2_not_null(row)
    unless row.radicanti_esterni.nil?
      if row.radicanti_esterni == 2
        unless !row.copertura.nil? && !row.altezza.nil? && row.eta_strutturale.nil? && row.danni_meccanici.nil? && row.danni_parassitari.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Radicanti Esterni = 2, violazione not null in copertura,altezza null in eta strutturale,danni meccanici,danni parassitari")
        end
      end
    end
  end

  #MP CHECK N4: Quando copertura !=0 altezza not null
  def altezza_not_null(row)
    unless row.copertura.nil?
      if row.copertura != 0
        if row.altezza.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"L'altezza non può essere nulla per un individuo.")
        end
      end
    end
  end

  #MP CHECK N5: Se copertura != 0 specie not null
  def specie_not_null(row)
    unless row.copertura.nil?
      if row.copertura != 0 && row.specie_id.nil?
        #segnalo l'errore
        multiple_parameter_error(row,"La specie non può essere nulla per un individuo.")
      end
    end
  end

  #MP CHECK N.6: Se copertura == 0 allora tutti gli altri campi devono essere nulli
  def cop0(row)
    unless row.copertura.nil?
      if row.copertura == 0
        unless row.altezza.nil? && row.specie_id.nil? && row.eta_strutturale.nil? && row.danni_meccanici.nil? && row.danni_parassitari.nil? && row.radicanti_esterni.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Se la copertura = 0, non devono essere presenti altri parametri.")
        end
      end
    end
  end

end