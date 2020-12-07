import { ContextStore } from './store/context.store';
import { Shader } from './Shader';
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppComponent } from './app.component';
import { WgfwDirective } from './directives/wgfw.directive';

@NgModule({
   declarations: [
      AppComponent,
      WgfwDirective
   ],
   imports: [
      BrowserModule
   ],
   providers: [
      ContextStore
   ],
   bootstrap: [
      AppComponent
   ]
})
export class AppModule { }
