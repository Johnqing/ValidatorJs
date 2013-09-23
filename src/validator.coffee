$ = jQuery

defaultConfig = 

	# 需要选中的元素
	target: '[require]'

	# 错误提示
	errorClass: 'error'

	# 执行事件
	event: 'blur'

	# 设置submit按钮
	# {false | String}
	submitBtn: false

	# debug
	debug: false

	# 前回调
	beforeCallback: ->

	# 后回调
	afterCallback: ->

validateSubmit = (opts) ->
	self = @

	if opts.submitBtn
		self.delegate(opts.submitBtn, 'click', (evt) ->			
			self.trigger('submit')
		)	

		self.submit( (evt) ->

			# debug模式下 不提交
			if opts.debug
				evt.preventDefault()
				return false;

			
			
		)	

	

$.fn.validate = (opts) ->
	opts = $.extend {}, defaultConfig, opts
	return @each( ->
		self = $(@)
		ident = opts.target

		# add novalidate
		# 去除默认样式
		self.attr("novalidate", "novalidate")

		# submit
		
		validateSubmit.call(@, opts)

		# 当用户聚焦到某个表单时去除错误提示
		self.on('focusein', ident, ->

		)		

		return
	)
