import { ajax } from 'discourse/lib/ajax';

export default {
	save(object) {
		if (object.get('disableSave')) return;

		var self = object;
	    self.set('savingStatus', I18n.t('saving'));
	    self.set('saving',true);

	    alert('saving');

		self.set('savingStatus', I18n.t('saved'));
		self.set('saving', false);
	}
}