module ApplicationHelper
  def css_class(organization)
    case organization.type
    when 'Institution'
      organization.css_class
    when 'Provider'
      organization.css_class
    when 'Program'
      css_class(organization.provider)
    when 'Core'
      css_class(organization.program)
    end
  end

  def controller_action
    params[:controller] + '/' + params[:action]
  end

  def line_item_visit_input line_item, visit, tab
    case tab
    when 'template'
      check_box_tag "service_requests[line_item_items][#{line_item.id}][visits][#{visit.id}]"
    when 'quantity'
      check_box_tag "service_requests[line_item_items][#{line_item.id}][visits][#{visit.id}]"
    when 'billing_strategy'
      check_box_tag "service_requests[line_item_items][#{line_item.id}][visits][#{visit.id}]"
    when 'pricing'
      "$0.00"
    end
  end


  def portal_link
    case Rails.env
    when "development"
      "localhost:3001"
    when "staging"
      "sparc-stg.musc.edu/portal"
    when "production"
      "sparc.musc.edu/portal"
    end
  end

  def navigation_link(img_or_txt, location)
    link_to img_or_txt, "javascript:void(0)", :class => 'navigation_link', :location => location
  end
end
