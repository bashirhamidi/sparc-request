# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<% if @arm.nil? %>
$(".otf-calendar").replaceWith("<%= escape_javascript(render('service_calendars/master_calendar/otf/otf_calendar', scroll_true: @scroll_true, tab: @tab, service_request: @service_request, sub_service_request: @sub_service_request, review: @review, portal: @portal, admin: @admin, merged: @merged, consolidated: @consolidated, statuses_hidden: %w(first_draft)))%>")
<% else %>
$(".arm-calendar-container-<%= @arm.id %>").replaceWith("<%= escape_javascript(render( '/service_calendars/master_calendar/pppv/pppv_calendar', tab: @tab, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, page: @pages[@arm.id], pages: @pages, review: @review, portal: @portal, admin: @admin, merged: @merged, consolidated: @consolidated, statuses_hidden: %w(first_draft))) %>")
<% end %>

<% if @portal %>
# Admin Edit
<% if @admin %>
$("#sub_service_request_header").html("<%= escape_javascript(render( 'dashboard/sub_service_requests/header', sub_service_request: @sub_service_request )) %>")
# View Consolidated Request -- All
<% else %>
<% @protocol.sub_service_requests.each do |ssr| %>
$("#sub_service_request_header").html("<%= escape_javascript(render( 'dashboard/sub_service_requests/header', sub_service_request: ssr )) %>")
<% end %>
<% end %>
<% end %>

$('.selectpicker').selectpicker()
setup_xeditable_fields(@scroll_true)
