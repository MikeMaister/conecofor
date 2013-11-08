module Erb_checks

  #--- Compliance ---

  #CHECK N1: FORMATO DATI
  #controllo che i campi integer e decimal abbiano
  #effettivamente valori interi o decimali immessi
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
    if record.copertura_esterna =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Copertura Esterna",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.altezza_media =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Altezza Media",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.numero_cespi =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Numero Cespi",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.numero_stoloni =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Numero Stoloni",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.numero_stoloni_radicanti =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Numero Stoloni Radicanti",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.numero_foglie =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Numero Foglie",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    if record.numero_getti =~ stringa
      #segnalo l'errore
      save_error(record,"Violazione tipo di dato - Numero Getti",row)
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
    #Opzionali
    if mandatory?(session[:mask_name],"Erbacee","copertura")
      if record.copertura.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","copertura_esterna")
      if record.copertura_esterna.nil?
        #registro l'errore
        save_error(record,"Violazione not null - Copertura Esterna",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","altezza_media")
      if record.altezza_media.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Altezza Media",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_cespi")
      if record.numero_cespi.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Cespi",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_stoloni")
      if record.numero_stoloni.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Stoloni",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_stoloni_radicanti")
      if record.numero_stoloni_radicanti.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Stoloni Radicanti",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_foglie")
      if record.numero_foglie.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Foglie",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","numero_getti")
      if record.numero_getti.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Numero Getti",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","danni_meccanici")
      if record.danni_meccanici.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Danni Meccanici",row)
        #segnalo che c'è stato un errore sulla riga
        session[:row_error] = true
        #e segnalo l'errore sul file
        session[:file_error] = true
      end
    end
    if mandatory?(session[:mask_name],"Erbacee","danni_parassitari")
      if record.danni_parassitari.nil? && !record.specie.blank?
        #registro l'errore
        save_error(record,"Violazione not null - Danni Parassitari",row)
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
    #una stessa specie deve essere presente 1 sola volta per ogni specifico plot-subplot
    if !record.specie.blank?
      #recupero tutte le info necessarie per memorizzare la chiave primaria
      plot_id = Plot.find(:first,:conditions => ["numero_plot = ? AND deleted = false",record.cod_plot]).id
      specie_id = Specie.find(:first, :conditions => ["descrizione = ? AND deleted = false", record.specie]).id
      active_campaign_id = Campagne.find(:first,:conditions => ["active = true"]).id
      file = ImportFile.find(session[:file_id])
      #cerco la chiave primaria
      pk = Erbacee.find(:first,:conditions => ["campagne_id = ? AND plot_id = ? AND subplot = ? AND file_name_id = ? AND import_num = ? AND specie_id = ?", active_campaign_id, plot_id, record.subplot, file.id, file.import_num,specie_id])
      #se già è presente
      unless pk.blank?
        #salvo l'errore #Specie già presente per il plot-subplot indicato#
        save_error(record,"Presenza duplicato",row)
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
    data_temp = Erbacee.new
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
    #a meno che il numero di subplot sia incluso tra 1 e 100
    unless (1..100).include?(record.subplot)
      #salvo l'errore
      save_error(record,"Wrong subplot",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
    end
    #COPERTURA ESTERNA
    #può essere 1 o nil
    unless record.copertura_esterna == 1 || record.copertura_esterna.nil?
      #salvo l'errore
      save_error(record,"Wrong Copertura Esterna",row)
      #segnalo che c'è stato un errore sulla riga
      session[:row_error] = true
      #e segnalo l'errore sul file
      session[:file_error] = true
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
    unless row.copertura.nil?
      copertura = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'copertura' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.copertura <= copertura[0].max && row.copertura >= copertura[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{copertura[0].attr}")
      end
    end
    #Legnose N.2
    #solo se altezza_media non è nullo
    unless row.altezza_media.nil?
      altezza_media = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'altezza_media' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.altezza_media <= altezza_media[0].max && row.altezza_media >= altezza_media[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{altezza_media[0].attr}")
      end
    end
    #Legnose N.3
    #solo se numero_cespi non è nullo
    unless row.numero_cespi.nil?
      n_cespi = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_cespi' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.numero_cespi <= n_cespi[0].max && row.numero_cespi >= n_cespi[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{n_cespi[0].attr}")
      end
    end
    #Legnose N.4
    #solo se numero_stoloni non è nullo
    unless row.numero_stoloni.nil?
      n_stoloni = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_stoloni' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.numero_stoloni <= n_stoloni[0].max && row.numero_stoloni >= n_stoloni[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{n_stoloni[0].attr}")
      end
    end
    #Legnose N.5
    #solo se numero_stoloni_radicanti non è nullo
    unless row.numero_stoloni_radicanti.nil?
      n_stoloni_rad = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_stoloni_radicanti' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.numero_stoloni_radicanti <= n_stoloni_rad[0].max && row.numero_stoloni_radicanti >= n_stoloni_rad[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{n_stoloni_rad[0].attr}")
      end
    end
    #Legnose N.6
    #solo se numero_foglie non è nullo
    unless row.numero_foglie.nil?
      n_foglie = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_foglie' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.numero_foglie <= n_foglie[0].max && row.numero_foglie >= n_foglie[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{n_foglie[0].attr}")
      end
    end
    #Legnose N.7
    #solo se numero_getti non è nullo
    unless row.numero_getti.nil?
      n_getti = SimpleRangeModel.find_by_sql ["SELECT * FROM simple_range_model WHERE attr = 'numero_getti' AND reference_table = 'erbacee' AND deleted = false AND id IN (SELECT simple_range_model_id FROM simple_range_association WHERE campagna_id = ? AND deleted = false )",camp_id]
      unless row.numero_getti <= n_getti[0].max && row.numero_getti >= n_getti[0].min
        #registro l'errore 'out of range NOME CAMPO'
        simple_range_error(row,"Out of range: #{n_getti[0].attr}")
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
    num_su_in = Erbacee.count_by_sql("SELECT COUNT(DISTINCT subplot) FROM erbacee WHERE campagne_id = #{open_camp.id} AND import_num = #{file.import_num} AND file_name_id = #{file.id}")

    #se i subplot non sono 100
    if num_su_in != 100
      #segnalo l'errore
      global_error("Mancano alcuni subplot",file)
    end
  end

  #MP CHECK N2: Quando la copertura = 0
  #tutti gli altri campi devono essere null
  def cop0_null(row)
    unless row.copertura.nil?
      if row.copertura == 0
        unless  row.copertura_esterna.nil? && row.altezza_media.nil? && row.numero_cespi.nil? && row.numero_stoloni.nil? && row.numero_stoloni_radicanti.nil? && row.numero_foglie.nil? && row.numero_getti.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Copertura = 0, other null")
        end
      end
    end
  end

  #MP CHECK N3: Se la specie è 'HEDERA HELIX',
  #copertura e copertura esterna devono essere not null,
  #mentre gli altri attributi null
  def hedera_helix_check(row)
    unless row.specie_id.blank?
      #cerco la specie Hedera helix
      hedera_helix = Specie.find(:first,:conditions => ["descrizione = 'Hedera helix' AND deleted = false"])
      if row.specie_id == hedera_helix.id
        unless !row.copertura.nil? && row.altezza_media.nil? && row.numero_cespi.nil? && row.numero_stoloni.nil? && row.numero_stoloni_radicanti.nil? && row.numero_foglie.nil? && row.numero_getti.nil?
          #segnalo l'errore
          multiple_parameter_error(row,"Hedera Helix check")
        end
      end
    end
  end

  #SR CHECK N3: verifica che le specie importate siano abituali o meno del plot
  def habitual_species(record)
    #se non ci sono dati approvati, vuol dire che è il primo import per quel plot
    dati_approvati = Erbacee.find(:all,:conditions => ["approved = true and temp = false and deleted = false and plot_id = ?",record.plot_id])
    unless dati_approvati.blank?
      #carico il file
      file = ImportFile.find(session[:file_id])
      #estrapolo tutte le specie abituali del plot
      habitual = Erbacee.find_by_sql ["select distinct specie_id as specie from erbacee where plot_id = ? and temp = false and approved = true and deleted = false",record.plot_id]
      trovato = false
      #scorro tutte le specie abituali
      for i in 0..habitual.size-1
        if record.specie_id == habitual.at(i).specie
          trovato = true
          break
        end
      end
      #genero il warning se trovato == false
      warning_error(record,"Speci abituali",file) if trovato == false
    end
  end

end