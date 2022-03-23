import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class GrantsUserDashboardSidebar extends NavigationMixin(LightningElement) {
     @track selectedTab = 'home';
    
    navigateToPage(event) {
        console.log(event.target.dataset.navigatepage);
        this.selectedTab = event.target.dataset.navigatepage;
    }

    get home(){
        return this.selectedTab == 'home';
    }
    get grantsManagement(){
        return this.selectedTab == 'grantsManagement';
    }
    get members(){
        return this.selectedTab == 'members';
    }
    get documentVault(){
        return this.selectedTab == 'documentVault';
    }
    get reports(){
        return this.selectedTab == 'reports';
    }
    get activity(){
        return this.selectedTab == 'activity';
    }

    
}