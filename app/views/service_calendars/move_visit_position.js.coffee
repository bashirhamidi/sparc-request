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
$(".arm-calendar-container-<%= @arm.id %> .pppv-thead").html('<%= j render "service_calendars/master_calendar/pppv/#{@tab}/#{@tab}_header", service_request: @service_request, sub_service_request: @sub_service_request, arm: @arm, tab: @tab, pages: @pages, page: @page.to_i, review: @review, portal: @portal, admin: @admin, merged: @merged, consolidated: @consolidated, statuses_hidden: @statuses_hidden %>')
$(".arm-calendar-container-<%= @arm.id %> .pppv-tbody").html('<%= j render "service_calendars/master_calendar/pppv/#{@tab}/#{@tab}_line_items", service_request: @service_request, sub_service_request: @sub_service_request, arm: @arm, tab: @tab, pages: @pages, page: @page.to_i, review: @review, portal: @portal, admin: @admin, merged: @merged, consolidated: @consolidated, statuses_hidden: @statuses_hidden %>')
$('.selectpicker').selectpicker()
$('#modal_place').modal('hide')
