import logging
 
def init(loglevel=logging.DEBUG,errlevel=logging.ERROR,filename='debug',filemode='a'):
	""" init the logger, must be called at first
	"""

	logging.basicConfig(level=loglevel,filename=filename+'.log',filemode=filemode,
		format='%(asctime)s $%(process)d %(name)s %(levelname)s %(filename)s: #%(lineno)d %(message)s')

	errHandler = logging.FileHandler(filename+'.err')
	errHandler.setLevel(errlevel)
	errHandler.setFormatter(logging.Formatter(
		'%(asctime)s $%(process)d %(name)s %(levelname)s %(filename)s: #%(lineno)d %(message)s'))

	logging.getLogger('').addHandler(errHandler)


def debugf(modulename):
	""" debugf wrapper
	"""
	return logging.getLogger(modulename).log
