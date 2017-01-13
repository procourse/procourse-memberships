import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax('/guild/levels');
  },

  findById(id) {
    return ajax(`/guild/l/${id}`);
  }
};