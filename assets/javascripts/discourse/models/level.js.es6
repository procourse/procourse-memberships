import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax('/memberships/levels');
  },

  findById(id) {
    return ajax(`/memberships/l/${id}`);
  }
};