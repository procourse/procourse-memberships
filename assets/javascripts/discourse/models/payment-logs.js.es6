import { ajax } from 'discourse/lib/ajax';

export default {
    
    findAll(filter) {
        return ajax(`/memberships/logs`, {
            data: { filter: filter }
        });
    }

};