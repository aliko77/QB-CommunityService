$('.dropdown').click(function () {
    $(this).attr('tabindex', 1).focus();
    $(this).toggleClass('active');
    $(this).find('.dropdown-menu').slideToggle(300);
});
$('.dropdown').focusout(function () {
    $(this).removeClass('active');
    $(this).find('.dropdown-menu').slideUp(300);
});
$('.dropdown-menu').click(function (e) {
    $(this).parents('.dropdown').find('.title').text(e.target.innerText);
    $(this).parents('.dropdown').find('.title').addClass('selected')
    $(this).parents('.dropdown').find('#target').attr('value', e.target.id);
});

$('#closeCommunityService').click(function (e) {
    e.preventDefault();
    $.post('https://nmr-communityservice/action', JSON.stringify({
        action: 'closePanel',
    }));
    $('.CommunityService').fadeOut();
    $('.dropdown-menu').html('');
    $('.dropdown .select .title').removeClass('selected')
    $('.dropdown .select .title').html('Ceza verilecek kişi')
    $('#CommunityService_amount').val('');
    $('#CommunityService_reason').val('');
})

$('#submitCommunityService').click(function (e) {
    e.preventDefault();
    var target = $('#target').attr('value'); 
    var amount = $('#CommunityService_amount').val();
    var reason = $('#CommunityService_reason').val();
    if (target == undefined || amount < 1 || reason == undefined || reason.length < 1) {
        $.post('https://nmr-communityservice/action', JSON.stringify({
            action: 'notify',
			message: "Alanları doğru doldurunuz...",
			type: 'error',
		}));
    }
    else if (amount > 50) {
        $.post('https://nmr-communityservice/action', JSON.stringify({
            action: 'notify',
			message: "Bu kadar yüksek ceza belirlenemez. (Max 50)",
			type: 'info',
		}));
    }else {
        $.post('https://nmr-communityservice/action', JSON.stringify({
            action: 'AddCommunityService',
            target: target,
            amount: amount,
            reason: reason
        }));
        $('.dropdown .select .title').removeClass('selected')
        $('.dropdown .select .title').html('Ceza verilecek kişi')
        $('#CommunityService_amount').val('');
        $('#CommunityService_reason').val('');
        $('.CommunityService').fadeOut();
    }
});

window.addEventListener('message', function(event){
    switch (event.data.action) {
        case 'openPanel':
            $('.dropdown-menu').html('');
            for (let index = 0; index < event.data.targets.length; index++) {
                const element = event.data.targets[index];
                let html = '<li id='+element.id+'>'+element.name+'</li>'
                $('.dropdown-menu').append(html)
            }
            $('.CommunityService').fadeIn();
            break;
        case 'setupInformationPanel':
            var display = $('.information-panel').css('display');
            $('.information-panel').find('h2').html('Kalan Ceza: '+event.data.amount)
            if (display == 'none')
                $('.information-panel').fadeIn();
            break;
        case 'finishpanel':
            $('.information-panel').find('h2').html('Kalan Ceza: 0')
            $('.information-panel').fadeOut();
            break;
        default:
            $.post('https://nmr-communityservice/action', JSON.stringify({
                action: 'notify',
                message: 'Event not found: '+event.data.action,
                type: 'error'
            }));
        break;
    }
})