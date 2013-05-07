class Plot < ActiveRecord::Base
  set_table_name "plot"

  attr_accessible :id_plot,:descrizione,:latitudine,:longitudine,:altitudine,:note,:deleted,:numero_plot,:im

  validates_presence_of :id_plot,:descrizione,:latitudine,:longitudine,:altitudine, :message => "non può essere vuoto."
  validates_format_of :id_plot, :with => /\d\d[A-Z][A-Z][A-Z]\d/, :message => "formato non valido."
  validates_length_of :descrizione, :maximum => 100 , :message => "massimo 100 caratteri."
  validates_format_of :latitudine, :longitudine, :with =>/[\+-\-]\d\d\d\d\d\d/, :message => "formato non valido."
  validates_numericality_of :altitudine, :message => "accetta solo caratteri numerici."
  validates_length_of :note, :maximum => 100 , :message => "massimo 200 caratteri."
  validate :no_dup, :unless => "id_plot.blank?"
  validates_format_of :im, :with => /[I][T]\d\d/, :message => "formato non valido.", :allow_blank => true

  def no_dup
    #carico tutti i plot non eliminati
    plot_list = Plot.find(:all,:conditions => ["deleted = false"])
    unless plot_list.blank?
      #per ogni plot
      plot_list.each do |plot|
        #carico il numero plot del plot corrente
        this_num_p = retrieve_num_plot(plot.id_plot)
        #carico il posto del plot corrente
        this_place = retrieve_plot_place(plot.id_plot)
        #se il numero plot è già assegnato ad un plot esistente
        if retrieve_num_plot(id_plot) == this_num_p
          #segnalo l'errore
          errors.add(:id_plot, "numero già assegnato.")
        end
        #se il posto è già assegnato ad un altro numero plot
        if retrieve_plot_place(id_plot) == this_place
          #segnalo l'errore
          errors.add(:id_plot, "luogo già assegnato.")
        end
      end
    end


  end

  def set_num_plot
    #ricavo il numero plot dall'id plot
    self.numero_plot = retrieve_num_plot(self.id_plot)
    #imposto anche il campo deleted a 0
    self.deleted = 0
  end

  def delete_it!
    self.update_attribute(:deleted,true)
    delete_dependencies(self.id)
  end

  private

  def retrieve_num_plot(id_p)
    format = /(\d)(\d)[A-Z][A-Z][A-Z]\d/
    if id_p =~ format
      num_p = $1 + "" + $2
    return num_p
    end
  end

  def retrieve_plot_place(id_p)
    format = /\d\d([A-Z])([A-Z])([A-Z])(\d)/
    if id_p =~ format
      place = $1 + "" + $2 + "" + $3 + "" + $4
      return place
    end
  end

  def delete_dependencies(plot_id)
    #Cops
    cops = Cops.find(:all, :conditions => ["plot_id = ?",plot_id])
    unless cops.blank?
      cops.each do |cs|
        cs.delete_it!
      end
    end

    #Copl
    copl = Copl.find(:all, :conditions => ["plot_id = ?",plot_id])
    unless copl.blank?
      copl.each do |cl|
        cl.delete_it!
      end
    end

    #Legnose
    legn = Legnose.find(:all, :conditions => ["plot_id = ?",plot_id])
    unless legn.blank?
      legn.each do |leg|
        leg.delete_it!
      end
    end

    #Erbacee
    erb = Erbacee.find(:all, :conditions => ["plot_id = ?",plot_id])
    unless erb.blank?
      erb.each do |e|
        e.delete_it!
      end
    end
  end

end
