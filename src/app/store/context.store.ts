import {EventEmitter, Injectable} from "@angular/core";

@Injectable()
export class ContextStore {
    private data: any = {};
    public change: EventEmitter<any> = new EventEmitter<any>();

    public storeContext(key: string, value: any): void {
        this.data[key] = value;
        this.change.emit({key, value});
    }

    public getContext(key: string, deleteKey: boolean = true): any {
        let tmpData: any = null;
        if (this.data.hasOwnProperty(key)) {
            tmpData = this.data[key];
            if (deleteKey) {
                delete this.data[key];
            }
        }

        return tmpData;
    }

    public flush(key: string): void {
        if (this.data.hasOwnProperty(key) ) {
            delete this.data[key];
            this.change.emit({key});
        }
    }

    public hasContext(key: string): boolean {
        return (this.data.hasOwnProperty(key) && this.data[key]);
    }
}
