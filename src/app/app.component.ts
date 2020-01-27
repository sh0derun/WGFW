import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit{

  public fps: number;

  ngOnInit() {
  }

  public getFps(event){
    this.fps = event;
  }

}
