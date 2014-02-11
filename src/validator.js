(function(globle){
    var document = globle.document;

    // 验证相关

    var idCard15To18 = function(id) {
        var A, W, i, j, newid, s;
        W = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1];
        A = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"];
        i = j = s = 0;
        newid = id;
        newid = newid.substring(0, 6) + "19" + newid.substring(6, id.length);
        for(; i < newid.length; i++){
            j = parseInt(newid.substring(i,i+1))*W[i]
            s = s + j
        };
        s = s % 11;
        newid = newid + A[s];
        return newid;
    };

    // 私有方法
    var checkable = function(element) {
        return /radio|checkbox/i.test(element.type);
    };

    function Form(field, config){
        if(!field.length) return;

        this.field = field;
        this.config = config;

        this.config.form = field.parents(config.form);

        this.init();

    }


    Form.prototype = {
        init: function(){
            var that = this;
            that.getValidItem(that.itemEvent);
            that.submitEvt();
        },
        logs: function(item){
            var that = this,
                config = that.config,
                node = config.form,
                t = arguments.length > 1,
                cls = t ? config.klass: config.fKlass

            var name = item.attr('data-form'),
                msg = validator.message[name] || config.message[name][t ? arguments[1] : 'focus'],
                errWrap = node.find('[data-errwrap=' + name + ']')

            if (item.not(':checkbox').not('radio').length) {
                item.removeClass(config.klass  +' '+ config.fKlass).addClass(cls);
            }

            if(!msg) return;

            if(errWrap.length){
                errWrap.removeClass(config.klass +' '+ config.fKlass  +' '+ config.success).addClass(cls).html(msg);
                return;
            }
            errWrap = $('<'+ config.errElem +' data-errwrap='+name+' class="'+cls+'">'+ msg +'</'+ config.errElem +'>');
            item.parent().append(errWrap);
        },
        succLog: function(item, rule){
            var that = this,
                config = that.config,
                name = item.attr('data-form'),
                node = config.form

            var errWrap = node.find('[data-errwrap=' + name + ']');
            item.removeClass(config.klass +' '+ config.fKlass);
            if (!errWrap.length) {
                return;
            }
            errWrap.text('').removeClass(config.klass +' '+ config.fKlass).addClass(config.success);
        },
        check: function(item, rules){
            var that = this,
                el = item[0],
                value = item.val(),
                result;
            // 如果元素上存在不需要验证的项，默认验证通过
            if(item.attr(that.config.dataIg)) return true;

            for(var rl in rules){
                var r = rules[rl],
                    method = validator.rules[rl];
                if(method){
                    result = method(value, el, r);

                    if(!result){
                        that.logs(item, rl);
                        return result;
                    }

                    that.succLog(item, rl);

                }
            }

            return result;
        },
        /**
         * 验证所有
         * @returns {boolean}
         */
        checkAll: function(){
            var that = this,
                arr = []

            that.getValidItem(function(item, key, rules){
                if(!that.check(item, rules)){
                    arr.push(key);
                }
            });

            return arr.length === 0
        },
        itemEvent: function(item, key, rules){
            var that = this;
            if(item[0].nodeName.toLowerCase() === 'select' || checkable(item[0])){
                that.config.event = 'change blur';
            }

            item.on(that.config.event, function() {
                that.check($(this), rules);
            });

            if(that.config.fKlass){
                item.on('focus', function(){
                    that.logs($(this));
                });
            }
        },
        submitEvt: function(){
            var that = this,
                field = that.field,
                node = that.config.form;

            if(that.config.isSubmit){
                field.on('click', function(){
                    node.trigger('submit');
                    return false;
                });

                node.on('submit', function(evt){
                    var st = that.checkAll();

                    if(that.config.debug && globle.console){
                        console.log(st);
                        evt.preventDefault();
                        return false;
                    }

                    return st;
                });
                return;
            }



        },
        getValidItem: function(callback){
            var that = this,
                node = that.config.form,
                rules = that.config.rules;

            for(var key in rules){
                var item = node.find('[data-form='+key+']');
                if(item.length){
                    callback && callback.call(that, item, key, rules[key]);
                }
            }
        }
    }

    var DEFAULTCONFIG = {
        rules: '[required]',
        dataIg: 'data-ig',
        klass: 'error',
        fKlass: null,
        success: 'success',
        form: '[data-type="form"]',
        event: 'blur',
        isSubmit: true,
        errElem: 'cite',
        debug: false
    };
    globle.validator = function(){
        return {
            init: function(els, config){
                if(!els) return;
                config = $.extend({}, DEFAULTCONFIG, config);
                return $(els).each(function(){
                    new Form($(this), config)
                });
            }
        }
    }();

    // 错误信息
    validator.message = validator.message || {};

    validator.rules = validator.rules || {
        required: function(value, elem){
            if (elem.nodeName.toLowerCase() === 'select') {
                return ~~elem.value;
            }
            if (checkable(elem)) {
                return getLength(value, elem) > 0;
            }
            return $.trim(value).length > 0;
        },
        minLen: function(value, elem, param) {
            return getByteLen(value) >= param;
        },
        equalTo: function(value, elem, param) {
            param = param.replace('#', '');
            var pv = $(elem).parents('[data-url]').find('[data-form=' + param + ']').val();
            return $.trim(pv) === $.trim(value);
        },
        // TODO: 根据运营商增加号段，手动维护
        isMobile: function(value){
            return /^(13|15|18|14)\d{9}$/.test(value)
        },
        /**
         * 身份证号验证
         */
        certificate: function(arrIdCard){
            arrIdCard = arrIdCard.replace(/\s/g, '');
            var a, check_number, number, sigma, w;
            arrIdCard = arrIdCard.length === 15 ? idCard15To18(arrIdCard) : arrIdCard;
            sigma = 0;
            a = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
            w = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"];

            for(var i = 0; i<17; i++){
                ai = parseInt(arrIdCard.substring(i, i + 1));
                wi = a[i]
                sigma += ai * wi
            }
            number = sigma % 11;
            check_number = w[number];

            return arrIdCard.substring(17) === check_number;

        }
    };
})(this);