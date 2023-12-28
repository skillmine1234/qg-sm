class SmAuditStepDecorator < ApplicationDecorator

  delegate_all

  def req_reference
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_req_bitstream_#{object.id}",
      title: "request_message".humanize,
      bitstream: object.req_bitstream,
      ref_no: (object.req_reference || 'Show'),
      button: 'd_clip_button1',
      xml: 'req_xml'
    }
  end

  def rep_reference
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_rep_bitstream_#{object.id}",
      title: "reply_message".humanize,
      bitstream: object.rep_bitstream,
      ref_no: (object.rep_reference || 'Show'),
      button: 'd_clip_button2',
      xml: 'rep_xml'
    }
  end

  def status_code
    h.render partial: 'shared/status', locals: {id: "#{object.class.name.demodulize}_status_code_#{object.id}", object: object}
  end
end