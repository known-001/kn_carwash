$(function()
{
    $(document).keyup(function (e) {
        if (e.keyCode == 27) {
            $('#container').fadeOut();
            $.post('http://kn_carwash/close', JSON.stringify({}));
        }
    });

    window.addEventListener('message', function(event)
    {
        var knData = event.data;
        if (knData.action == 'open') {
            $('#container').fadeIn();
            $('#amount').html(knData.amount);
        } else if (knData.action = 'close') {
            $('#container').fadeOut();
        }

    }, false);

    $("#wash").click(function () { $.post('http://kn_carwash/wash', JSON.stringify({})); $(this).blur(); });

});