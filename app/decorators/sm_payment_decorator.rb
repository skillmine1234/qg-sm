class SmPaymentDecorator < ApplicationDecorator
  delegate_all
  
  def status_code
    h.render partial: 'shared/status', locals: {id: "#{object.class.name.demodulize}_status_code_#{object.id}", object: object}
  end
  
  def transfer_amount
    h.number_to_currency(object.transfer_amount, unit: 'Rs ')
  end
  
  def reconciled_at
    object.reconciled_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end

  def req_timestamp
    object.req_timestamp.try(:strftime, "%d/%m/%Y %I:%M%p")
  end

  def rep_timestamp
    object.rep_timestamp.try(:strftime, "%d/%m/%Y %I:%M%p")
  end
  
  def request
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_req_bitstream_#{object.id}",
      title: "request_message".humanize,
      bitstream: object.audit_log.try(:req_bitstream),
      ref_no: object.req_no,
      button: 'd_clip_button1',
      xml: 'req_xml'}
  end
  
  def reply
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_rep_bitstream_#{object.id}", 
      title: "reply_message".humanize, 
      bitstream: object.audit_log.try(:rep_bitstream), 
      ref_no: (object.rep_no || 'Show' ),
      button: 'd_clip_button2',
      xml: 'rep_xml'}
  end
  
  def steps
    h.link_to 'Show', h.send("steps_sm_payment_path", object)
  end
end