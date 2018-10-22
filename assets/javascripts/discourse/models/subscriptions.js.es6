import { ajax } from 'discourse/lib/ajax';

export default {
  findAll(user_id) {
    return ajax(`/memberships/subscriptions/${user_id}`);
  },

  findById(user_id, id) {
    return ajax(`/memberships/subscriptions/${user_id}/${id}`);
  },
  destroy(id){
    return ajax(`/memberships/subscriptions/${id}`, { 
        type: 'DELETE'});
  }
};