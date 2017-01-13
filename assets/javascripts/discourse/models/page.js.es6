import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax('/guild/pages');
  },

  findById(opts) {
    return ajax(`/guild/p/${opts.id}`);
  }
};