module Cops_checks

  #--- Compliance ---

  #CHECK N1: FORMATO DATI
  #controllo che i campi integer abbiano effettivamente valori interi immessi
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
    if record.in_out =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - In/Out",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.priest =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Pri/Est",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.cod_strato =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Strato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.substrate =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Substrate Type",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.certainty_species_determination =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Certainty Species Determination",row)
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
    if record.in_out.blank?
      #registro l'errore
      save_error(record,"Violazione not null - In/Out",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.priest.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Pri/Est",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.cod_strato.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Strato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.specie.blank?
      #registro l'errore
      save_error(record,"Violazione not null - Specie",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #FACOLTATIVI
    if mandatory?(session[:mask_name],"Cops","copertura_specifica") == true
      if record.copertura.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Cops","substrate")
      if record.substrate.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Substrate",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Cops","certainty_species_determination")
      if record.certainty_species_determination.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Certainty Species Determination",row)
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
    #riferimenti alla copertura specifica
    unless record.copertura.blank?
      cop_spec = CoperturaSpecifica.find(:first, :conditions => ["identifier = ?",record.copertura])
      if cop_spec.blank?
        save_error(record,"Riferimento a Copertura Specifica",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #riferimenti a substrate
    unless record.substrate.blank?
      sub = SubstrateType.find(:first, :conditions => ["code = ?",record.substrate])
      if sub.blank?
        save_error(record,"Riferimento a Substrate Type",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    #riferimenti a substrate
    unless record.certainty_species_determination.blank?
      csd = CertaintySpeciesDetermination.find(:first, :conditions => ["code = ?",record.certainty_species_determination])
      if csd.blank?
        save_error(record,"Riferimento a Certainty Species Determination",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
  end

  #CHECK N4: UNICITA' RECORD
  def unique_record_check(record,row)
    #recupero tutte le info necessarie per memorizzare la chiave primaria
    plot_id = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false",record.cod_plot]).id
    specie_id = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]).id
    active_campaign_id = Campagne.find(:first,:conditions => ["active = true"]).id
    file = ImportFile.find(session[:file_id])
    #cerco la chiave primaria
    pk = Cops.find(:first,:conditions => ["campagne_id = ? AND plot_id = ? AND subplot = ? AND in_out = ? AND specie_id = ? AND codice_strato = ? AND priest = ? AND file_name_id = ? AND import_num = ?", active_campaign_id, plot_id, record.subplot, record.in_out, specie_id, record.cod_strato, record.priest, file.id, file.import_num])
    #se già è presente
    if pk
      #salvo l'errore
      save_error(record,"Presenza duplicato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
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
    data_temp = Cops.new
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

  #CHECK N7: CORRISPONDENZA STAGIONE FILE - STAGIONE CAMPAGNA
  def file_season(record,row)
    camp_season_identifier = Season.find(Campagne.find(:first,:conditions => ["active = true"]).season_id).identifier
    #a meno che il numero di stagione corrisponda a quella scelta dall'utente
    unless record.priest == camp_season_identifier
      #salvo l'errore
      save_error(record,"Stagione campagna - Stagione file",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #CHECK N8: DOMINIO DEGLI ATTRIBUTI
  def attr_domain(record,row)
    #SUBPLOT
    #a meno che il numero di subplot sia incluso tra 1 e 12
    unless (1..12).include?(record.subplot)
      #salvo l'errore
      save_error(record,"Wrong subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #IN_OUT
    #a meno che esterno valga 1 o 2
    unless (1..2).include?(record.in_out)
      #salvo l'errore
      save_error(record,"Wrong in_out",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #PRIEST
    #a meno che priest valga 1 o 2
    #unless (1..2).include?(record.priest)
    est_identifier = Season.find_by_nome("Estate").identifier
    pri_identifier = Season.find_by_nome("Primavera").identifier
    unless record.priest == est_identifier || record.priest == pri_identifier
      #salvo l'errore
      save_error(record,"Wrong Pri/Est",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #COD_STRATO
    #a meno che cod_strato valga 1,2,3 o 4
    unless (1..4).include?(record.cod_strato)
      #salvo l'errore
      save_error(record,"Wrong Cod_strato",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
  end

  #--- Simple Range ---

  #SR CHECK N1: controlla che la data del record rientri in quella della campagna
  def data_range(record)
    #carico la campagna attiva
    camp = Campagne.find(:first,:conditions => ["active = true"])
    #a meno che la data non rientri nel range della campagna
    unless record.data >= camp.inizio && record.data <= camp.fine
      #salvo l'errore simple range
      simple_range_error(record,"Data range")
    end
  end

  #--- Multiple Parameter ---

  #MP CHECK N1: specie eu
  def specie_eu(record)
    str = /^[3-5]/
    #se il codice strato è uguale a 4
    if record.codice_strato == 4
      #rintraccio la specie del record attuale
      specie = Specie.find(record.specie_id)
      #se la specie europea corrispondente esiste
      unless specie.euflora_id.blank?
        #la rintraccio rintraccio
        eu_specie = Euflora.find(specie.euflora_id)
        #a meno che il codice europeo della specie del record non inizi per 3,4 o 5 allora c'è un errore
        unless eu_specie.codice_eu.to_s =~ str
          #segnalo l'errore
          multiple_parameter_error(record,"[strato - specie - eu code] violation")
        end
      end
    end
  end

  #MP CHECK N2: verifica la presenza di tutti i subplot
  def all_subplot?
    #trovo la campagna aperta
    open_camp = Campagne.find(:first,:conditions => ["active = true"])
    #carico il file
    file = ImportFile.find(session[:file_id])
    #memorizzo il numero dei subplot diversi tra loro interni
    num_su_in = Cops.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM cops WHERE campagne_id = #{open_camp.id} AND in_out = 1 AND import_num = #{file.import_num} AND file_name_id = #{file.id}")
    #memorizzo il numero dei subplot diversi tra loro esterni
    num_su_out = Cops.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM cops WHERE campagne_id = #{open_camp.id} AND in_out = 2 AND import_num = #{file.import_num} AND file_name_id = #{file.id}")
    #se i subplot interni non sono 12
    if num_su_in != 12
      #segnalo l'errore
      global_error("Mancano alcuni subplot interni",file)
    end
    #se i subplot esterni non sono 12
    if num_su_out != 12
      #segnalo l'errore
      global_error("Mancano alcuni subplot esterni",file)
    end
  end

  #SR CHECK N3: verifica che le specie importate siano abituali o meno del plot
  def habitual_species(record)
    #se non ci sono dati approvati, vuol dire che è il primo import
    dati_approvati = Cops.find(:all,:conditions => ["approved = true and temp = false and deleted = false and plot_id = ?",record.plot_id])
    unless dati_approvati.blank?
      #carico il file
      file = ImportFile.find(session[:file_id])
      #estrapolo tutte le specie abituali del plot
      habitual = Cops.find_by_sql ["select distinct specie_id as specie from cops where plot_id = ? and temp = false and approved = true and deleted = false",record.plot_id]
      trovato = false
      #scorro tutte le specie abituali
      for i in 0..habitual.size-1
        if record.specie_id == habitual.at(i).specie
          trovato = true
          break
        end
      end
      #genero il warning se trovato == false
      warning_error(record,"habitual species",file) if trovato == false
    end
  end

end